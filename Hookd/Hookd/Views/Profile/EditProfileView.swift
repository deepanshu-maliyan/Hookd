import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var bio: String
    @State private var selectedIntent: String
    @State private var selectedTags: Set<String>
    @State private var photos: [String]
    @State private var newPhotos: [PhotoItem] = []
    @State private var showPhotoPicker = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    let intents = ["serious", "casual", "hookup", "fwb", "explore"]
    let allTags = [
        "threesome", "fwb", "bdsm", "voyeur", "open-relationship",
        "casual", "no-labels", "poly", "roleplay", "vanilla",
        "older-partner", "younger-partner", "exhibitionist", "queer", "long-distance"
    ]
    
    init() {
        let user = AppState().currentUser
        _bio = State(initialValue: user?.bio ?? "")
        _selectedIntent = State(initialValue: user?.intent ?? "explore")
        _selectedTags = State(initialValue: Set(user?.fantasyTags ?? []))
        _photos = State(initialValue: user?.photos ?? [])
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Photos")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(photos.enumerated()), id: \.offset) { index, photoUrl in
                                    ZStack(alignment: .topTrailing) {
                                        AsyncImage(url: URL(string: photoUrl)) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            } else {
                                                Color.gray
                                            }
                                        }
                                        .frame(width: 100, height: 140)
                                        .cornerRadius(12)
                                        .clipped()
                                        
                                        Button(action: { photos.remove(at: index) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                        .padding(6)
                                    }
                                }
                                
                                ForEach(Array(newPhotos.enumerated()), id: \.offset) { index, photo in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: photo.image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 140)
                                            .cornerRadius(12)
                                            .clipped()
                                        
                                        Button(action: { newPhotos.remove(at: index) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                        .padding(6)
                                    }
                                }
                                
                                if photos.count + newPhotos.count < 6 {
                                    Button(action: { showPhotoPicker = true }) {
                                        VStack {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(.pink)
                                            Text("Add")
                                                .font(.caption)
                                        }
                                        .frame(width: 100, height: 140)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bio")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextEditor(text: $bio)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        
                        Text("\(bio.count)/500")
                            .font(.caption)
                            .foregroundColor(bio.count > 500 ? .red : .secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Looking For")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Picker("Intent", selection: $selectedIntent) {
                            ForEach(intents, id: \.self) { intent in
                                Text(displayIntent(intent)).tag(intent)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vibes (\(selectedTags.count)/10)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                            ForEach(allTags, id: \.self) { tag in
                                Button(action: { toggleTag(tag) }) {
                                    Text(tag.replacingOccurrences(of: "-", with: " ").capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedTags.contains(tag) ? .white : .primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedTags.contains(tag) ?
                                            LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing) :
                                            LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .cornerRadius(16)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: handleSave) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isSaving || !isValid)
                }
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPickerView(selectedPhotos: $newPhotos, maxSelection: 6 - photos.count - newPhotos.count)
            }
        }
    }
    
    private var isValid: Bool {
        !selectedTags.isEmpty && selectedTags.count <= 10 && bio.count <= 500 && (photos.count + newPhotos.count) >= 2
    }
    
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else if selectedTags.count < 10 {
            selectedTags.insert(tag)
        }
    }
    
    private func displayIntent(_ intent: String) -> String {
        switch intent {
        case "serious": return "Serious"
        case "casual": return "Casual"
        case "hookup": return "Hookup"
        case "fwb": return "FWB"
        case "explore": return "Explore"
        default: return intent.capitalized
        }
    }
    
    private func handleSave() {
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                var updatedPhotos = photos
                
                for photo in newPhotos {
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
                    
                    updatedPhotos.append(presignedResponse.cdnUrl)
                }
                
                let updatedUser = try await APIClient.shared.updateProfile(
                    bio: bio,
                    intent: selectedIntent,
                    fantasyTags: Array(selectedTags),
                    photos: updatedPhotos
                )
                
                appState.updateUser(updatedUser)
                dismiss()
            } catch {
                errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            }
            
            isSaving = false
        }
    }
}
