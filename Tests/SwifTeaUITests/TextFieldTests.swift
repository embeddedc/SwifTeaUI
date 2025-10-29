import Testing
@testable import SwifTeaCore
@testable import SwifTeaUI

struct TextFieldTests {

    private struct Harness {
        @State var value = ""
        var binding: Binding<String> { $value }
    }

    @Test("Text input binding supports character insertion and backspace")
    func testApplyEdits() {
        let harness = Harness()
        let binding = harness.binding

        binding.apply(.insert("A"))
        binding.apply(.insert("b"))
        #expect(harness.value == "Ab")

        binding.apply(.backspace)
        #expect(harness.value == "A")
    }

    @Test("Text field renders current value with cursor when focused")
    func testRenderMirrorsBinding() {
        let harness = Harness()
        let binding = harness.binding
        let field = TextField("Prompt", text: binding, cursor: "|")

        #expect(field.render() == "Prompt|")

        binding.apply(.insert("X"))
        #expect(field.render() == "X|")
    }

    @Test("Text field removes cursor when focus binding is false")
    func testRenderWithoutFocus() {
        let harness = Harness()
        let binding = harness.binding
        var isFocused = false
        let focus = Binding<Bool>(
            get: { isFocused },
            set: { isFocused = $0 }
        )

        let field = TextField("Placeholder", text: binding, focus: focus, cursor: "|")
        #expect(field.render() == "Placeholder")

        isFocused = true
        #expect(field.render() == "Placeholder|")
    }

    @Test("Key events map to text field events")
    func testEventMapping() {
        #expect(textFieldEvent(from: .char("a")) == .insert("a"))
        #expect(textFieldEvent(from: .backspace) == .backspace)
        #expect(textFieldEvent(from: .enter) == .submit)
        #expect(textFieldEvent(from: .leftArrow) == nil)
    }

    @Test("Focus bindings toggle wrapped focus value")
    func testFocusStateBinding() {
        struct FocusHarness {
            enum Field: Hashable { case note }
            @FocusState var field: Field?
        }

        let harness = FocusHarness()
        let focusBinding = harness.$field.isFocused(.note)

        #expect(harness.field == nil)
        #expect(focusBinding.wrappedValue == false)

        focusBinding.wrappedValue = true
        #expect(harness.field == .note)

        focusBinding.wrappedValue = false
        #expect(harness.field == nil)
    }
}
