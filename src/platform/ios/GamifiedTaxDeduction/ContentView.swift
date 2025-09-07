import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Gamified Tax Deduction")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Track receipts, save money, build habits")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Main Dashboard Content
                VStack(spacing: 20) {
                    // Potential Savings Card
                    VStack(spacing: 12) {
                        Text("Total Potential Savings")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("$0.00")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                        
                        Text("This Year")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(24)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Progress Section
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Receipts Scanned")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("0")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Current Streak")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("0 days")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Primary Action Button
                Button(action: {
                    // TODO: Implement camera scanning
                    print("Scan Receipt tapped")
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Scan New Receipt")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}