import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var age = 21
    @State private var gender = "Male"
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let genderOptions = ["Male", "Female", "Non-binary", "Other"]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.orange.opacity(0.3), Color(red: 1.0, green: 0.5, blue: 0).opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 8) {
                        Text("🔥")
                            .font(.system(size: 60))
                        
                        Text("Join Hookd")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, Color(red: 1.0, green: 0.5, blue: 0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Create your account")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        TextField("Full Name", text: $name)
                            .textFieldStyle(CustomTextFieldStyle())
                            .textContentType(.name)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                            .textContentType(.newPassword)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(CustomTextFieldStyle())
                            .textContentType(.newPassword)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Age")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Picker("Age", selection: $age) {
                                ForEach(18...100, id: \.self) { age in
                                    Text("\(age)").tag(age)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gender")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Picker("Gender", selection: $gender) {
                                ForEach(genderOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: handleRegister) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Create Account")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.orange, Color(red: 1.0, green: 0.5, blue: 0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                        .disabled(isLoading || !isFormValid)
                        .opacity((isLoading || !isFormValid) ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        age >= 18
    }
    
    private func handleRegister() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await appState.register(
                    email: email,
                    password: password,
                    name: name,
                    age: age,
                    gender: gender
                )
            } catch {
                errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            }
            isLoading = false
        }
    }
}
