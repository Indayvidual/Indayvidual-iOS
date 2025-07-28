import SwiftUI
import PhotosUI

struct TimetableView: View {
    
    @StateObject private var viewModel = TimetableViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Topbar()
            Spacer().frame(height: 10)
            
            DropdownBar(
                hint: "미정",
                options: viewModel.dropdownOptions,
                selection: $viewModel.selection
            )
            .padding(.horizontal, 15)
            .zIndex(1)
            
            Spacer().frame(height: 22)
            
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else if viewModel.dropdownOptions.isEmpty {
                EmptyTimeTableView()
            }
            
            Spacer()
        }
        .floatingBtn {
            viewModel.showSchoolSheet = true
        }
        .sheet(isPresented: $viewModel.showSchoolSheet) {
            SchoolSelectionSheet(
                showSemesterSheet: $viewModel.showSemesterSheet,
                selectedSchoolName: Binding(
                    get: { viewModel.selectedSchoolName ?? "" },
                    set: { viewModel.selectedSchoolName = $0 }
                )
            )
        }
        .sheet(isPresented: $viewModel.showSemesterSheet, onDismiss: viewModel.handleSemesterSheetDismiss) {
            SemesterSelectionSheet(
                isPresented: $viewModel.showSemesterSheet,
                selectedSemester: Binding(
                    get: { viewModel.selectedSemester ?? "" },
                    set: { viewModel.selectedSemester = $0 }
                )
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.height(350)])
        }
        .photosPicker(
            isPresented: $viewModel.showImagePicker,
            selection: $viewModel.selectedPhotoItem,
            matching: .images
        )
        .background(Color(.gray50))
    }
}

#Preview {
    TimetableView()
}
