import SwiftUI
import PhotosUI

struct PostConfessionView: View {
    @Environment(\.dismiss) var dismiss
    let onPost: (Confession) -> Void
    
    @State private var confessionText = ""
    @State private var isAnonymous = true
    @State private var selectedPhoto: PhotoItem?
    @State private var showPhotoPicker = false
    @State private var isPosting = false
    @State private var errorMessage: String?
    
    let characterLimit = 500
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What's on your mind?")
                                .font(.headline)
                            
                            TextEditor(text: $confessionText)
                                .frame(minHeight: 150)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            
                            HStack {
                                Text("\(confessionText.count)/\(characterLimit)")
                                    .font(.caption)
                                    .foregroundColor(confessionText.count > characterLimit ? .red : .secondary)
                                
                                Spacer()
                            }
                        }
                        
                        if let photo = selectedPhoto {
                            VStack {
                                Image(uiImage: photo.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .cornerRadius(12)
                                    .clipped()
                                
                                Button(action: { selectedPhoto = nil }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Remove Photo")
                                    }
                                    .foregroundColor(.red)
                                }
                            }
                        } else {
                            Button(action: { showPhotoPicker = true }) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle")
                                    Text("Add Photo (Optional)")
                                }
                                .foregroundColor(.pink)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                            }
                        }
                        
                        Toggle(isOn: $isAnonymous) {
                            HStack {
                                Image(systemName: "theatermasks.fill")
                                    .foregroundColor(.orange)
                                Text("Post Anonymously")
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("New Confession")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: handlePost) {
                        if isPosting {
                            ProgressView()
                        } else {
                            Text("Post")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isPosting || confessionText.isEmpty || confessionText.count > characterLimit)
                }
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPickerSingleView(selectedPhoto: $selectedPhoto)
            }
        }
    }
    
    private func handlePost() {
        isPosting = true
        errorMessage = nil
        
        Task {
            do {
                var imageUrl: String?
                
                if let photo = selectedPhoto,
                   let imageData = photo.image.jpegData(compressionQuality: 0.8) {
                    let filename = "confession_\(UUID().uuidString).jpg"
                    let presignedResponse = try await APIClient.shared.getPresignedUrl(
                        filename: filename,
                        contentType: "image/jpeg"
                    )
                    
                    try await APIClient.shared.uploadToPresignedUrl(
                        url: presignedResponse.uploadUrl,
                        data: imageData,
                        contentType: "image/jpeg"
                    )
                    
                    imageUrl = presignedResponse.cdnUrl
                }
                
                let confession = try await APIClient.shared.createConfession(
                    body: confessionText,
                    imageUrl: imageUrl,
                    isAnonymous: isAnonymous
                )
                
                onPost(confession)
                dismiss()
            } catch {
                errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            }
            
            isPosting = false
        }
    }
}

struct PhotoPickerSingleView: UIViewControllerRepresentable {
    @Binding var selectedPhoto: PhotoItem?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerSingleView
        
        init(_ parent: PhotoPickerSingleView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let result = results.first else { return }
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self?.parent.selectedPhoto = PhotoItem(image: image)
                        }
                    }
                }
            }
        }
    }
}
