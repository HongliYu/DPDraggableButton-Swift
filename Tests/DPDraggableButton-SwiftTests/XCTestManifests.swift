import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(DPDraggableButton_SwiftTests.allTests),
    ]
}
#endif
