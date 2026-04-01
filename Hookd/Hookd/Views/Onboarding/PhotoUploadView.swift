import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedPhotos: [PhotoItem] = []
    @State private var showPhotoPicker = false
    @State private var isUploading = false
    @State private var uploadProgress: Double = 0
    @State private var errorMessage: String?
    @State private var uploadedCDNUrls: [String] = []
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.pink.opacity(0.2), Color.orange.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                VStack(spacing: 12) {
                    Text("📸")
                        .font(.system(size: 60))
                    
                    Text("Show Your Best Self")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    
                    Text("Add 2-6 photos. First impressions matter!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                
                Text("\(selectedPhotos.count)/6 photos")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(selectedPhotos.count < 2 ? .red : .green)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                        ForEach(Array(selectedPhotos.enumerated()), id: \.offset) { index, photo in
                            PhotoThumbnail(photo: photo, index: index) {
                                selectedPhotos.remove(at: index)
                            }
                        }
                        
                        if selectedPhotos.count < 6 {
                            AddPhotoButton {
                                showPhotoPicker = true
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                if isUploading {
                    VStack(spacing: 8) {
                        ProgressView(value: uploadProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                        Text("Uploading photos...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Button(action: handleContinue) {
                    HStack {
                        if isUploading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Complete Profile")
                                .fontWeight(.semibold)
                            Image(systemName: "checkmark")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [.pink, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .disabled(selectedPhotos.count < 2 || isUploading)
                .opacity((selectedPhotos.count < 2 || isUploading) ? 0.6 : 1.0)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView(selectedPhotos: $selectedPhotos, maxSelection: 6 - selectedPhotos.count)
        }
    }
    
    private func handleContinue() {
        isUploading = true
        errorMessage = nil
        uploadedCDNUrls = []
        
        Task {
            do {
                let total = Double(selectedPhotos.count)
                
                for (index, photo) in selectedPhotos.enumerated() {
                    guard let imageData = photo.image.jpegData(compressionQuality: 0.8) else { continue }
                    
                    let filename = "photo_\(UUID().uuidString).jpg"
                    let presignedResponse = try await APIClient.shared.getPresignedUrl(
                        filename: filename,
                        contentType: "image/jpeg"
                    )
                    
                    try await APIClient.shared.uploadToPresignedUrl(
                        url: presignedResponse.uploadUrl,
                        data: imageData,
                        contentType: "image/jpeg"
                    )
                    
                    uploadedCDNUrls.append(presignedResponse.cdnUrl)
                    uploadProgress = Double(index + 1) / total
                }
                
                let updatedUser = try await APIClient.shared.updateProfile(
                    bio: nil,
                    intent: nil,
                    fantasyTags: nil,
                    photos: uploadedCDNUrls
                )
                
                appState.updateUser(updatedUser)
                appState.completeOnboardingStep()
            } catch {
                errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            }
            
            isUploading = false
        }
    }
}

struct PhotoItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct PhotoThumbnail: View {
    let photo: PhotoItem
    let index: Int
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: photo.image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if index == 0 {
                Text("Main")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.pink)
                    .cornerRadius(6)
                    .padding(6)
                    .offset(x: 0, y: -6)
            }
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding(6)
        }
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct AddPhotoButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.gray)
                
                Text("Add Photo")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(width: 100, height: 140)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(.gray)
            )
        }
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedPhotos: [PhotoItem]
    let maxSelection: Int
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = maxSelection
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView
        
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self?.parent.selectedPhotos.append(PhotoItem(image: image))
                            }
                        }
                    }
                }
            }
        }
    }
}
