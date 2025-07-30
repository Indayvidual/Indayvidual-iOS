import SwiftUI
import PhotosUI

@MainActor
class TimetableViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var selection: String? {
        didSet {
            if let sel = selection {
                selectedImage = timetableImages[sel]
            } else {
                selectedImage = nil
            }
        }
    }
    @Published var selectedImage: UIImage?
    @Published var dropdownOptions: [String] = []
    @Published var timetableImages: [String: UIImage] = [:]
    
    @Published var showSchoolSheet = false
    @Published var showSemesterSheet = false
    @Published var showImagePicker = false // PhotosPicker 표시를 제어하기 위한 프로퍼티
    
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet {
            Task {
                await processSelectedPhoto()
            }
        }
    }
    
    var selectedSchoolName: String?
    var selectedSemester: String?
    
    // MARK: - Methods
    
    func handleSemesterSheetDismiss() {
        guard let school = selectedSchoolName, let semester = selectedSemester else { return }
        
        let newEntry = "\(school) \(semester)"
        if !dropdownOptions.contains(newEntry) {
            dropdownOptions.append(newEntry)
        }
        selection = newEntry
        
        // 새로 추가된 항목에 이미지가 없다면 PhotosPicker를 띄움
        if timetableImages[newEntry] == nil {
            showImagePicker = true
        }
    }
    
    private func processSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data),
               let key = selection {
                
                DispatchQueue.main.async {
                    self.timetableImages[key] = image
                    self.selectedImage = image
                    self.selectedPhotoItem = nil // 다음 선택을 위해 초기화
                }
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }
}
