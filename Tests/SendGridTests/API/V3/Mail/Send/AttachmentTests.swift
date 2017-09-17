//
//  AttachmentTests.swift
//  SendGridTests
//
//  Created by Scott Kawai on 9/14/17.
//

import XCTest
@testable import SendGrid

class AttachmentTests: XCTestCase, EncodingTester {
    
    typealias EncodableObject = Attachment
    let redDotBytes: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 5, 0, 0, 0, 5, 8, 6, 0, 0, 0, 141, 111, 38, 229, 0, 0, 0, 28, 73, 68, 65, 84, 8, 215, 99, 248, 255, 255, 63, 195, 127, 6, 32, 5, 195, 32, 18, 132, 208, 49, 241, 130, 88, 205, 4, 0, 14, 245, 53, 203, 209, 142, 14, 31, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130]
    let dotBase64: String = "iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg=="
    
    func testEncoding() {
        let data = Data(bytes: self.redDotBytes)
        let minimalAttachment = Attachment(filename: "red.png", content: data)
        XCTAssertEncodedObject(minimalAttachment, equals: [
            "content": self.dotBase64,
            "filename": "red.png",
            "disposition": "attachment"
            ]
        )
        
        let maxAttachment = Attachment(filename: "red-dot.png", content: data, disposition: .inline, type: .png, contentID: "ABC-123")
        XCTAssertEncodedObject(maxAttachment, equals: [
            "content_id": "ABC-123",
            "content": self.dotBase64,
            "filename": "red-dot.png",
            "type": "image/png",
            "disposition": "inline"
            ]
        )
    }
    
    func testInitialization() {
        let data = Data(bytes: self.redDotBytes)
        let basic = Attachment(filename: "dot.png", content: data)
        XCTAssertEqual(basic.filename, "dot.png")
        XCTAssertEqual(basic.disposition, ContentDisposition.attachment)
        XCTAssertNil(basic.contentID)
        XCTAssertNil(basic.type)
        
        let advance = Attachment(filename: "dot_inline.png", content: data, disposition: ContentDisposition.inline, type: ContentType.png, contentID: "dot")
        XCTAssertEqual(advance.filename, "dot_inline.png")
        XCTAssertEqual(advance.disposition, ContentDisposition.inline)
        XCTAssertEqual(advance.type!.description, ContentType.png.description)
        XCTAssertEqual(advance.contentID, "dot")
    }
    
    func testValidation() {
        let image = Data(bytes: self.redDotBytes)
        do {
            // Validation should pass with a valid content type.
            let good = Attachment(filename: "dot.png", content: image, disposition: .attachment, type: .png, contentID: nil)
            try good.validate()
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        do {
            // Validation should pass when no content type is present.
            let good = Attachment(filename: "dot.png", content: image)
            try good.validate()
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        do {
            // Should fail when content type has a semicolon.
            let semicolon = Attachment(filename: "dot.png", content: image, disposition: .attachment, type: ContentType(type: "image", subtype: "png;"), contentID: nil)
            try semicolon.validate()
            XCTFail("Expected errot to be thrown when providing a content type with a semicolon, but no error was thrown")
        } catch SendGrid.Exception.ContentType.invalidContentType(let errorType) {
            XCTAssertEqual(errorType, "image/png;")
        } catch {
            XCTFail("An unexpected error was thrown: \(error)")
        }
        
        do {
            // Should fail when content type has a newline.
            let newline = Attachment(filename: "dot.png", content: image, disposition: .attachment, type: ContentType(type: "image", subtype: "png\n\n"), contentID: nil)
            try newline.validate()
            XCTFail("Expected errot to be thrown when providing a content type with a newline, but no error was thrown")
        } catch SendGrid.Exception.ContentType.invalidContentType(let errorType) {
            XCTAssertEqual(errorType, "image/png\n\n")
        } catch {
            XCTFail("An unexpected error was thrown: \(error)")
        }
        
        do {
            // Should fail if filename has semicolons and newlines.
            let newline = Attachment(filename: "dot;\n.png", content: image, disposition: .attachment, type: .png, contentID: nil)
            try newline.validate()
            XCTFail("Expected error to be thrown when providing a filename with a semicolon, but no error was thrown")
        } catch SendGrid.Exception.Mail.invalidFilename(let errorName) {
            XCTAssertEqual(errorName, "dot;\n.png")
        } catch {
            XCTFail("An unexpected error was thrown: \(error)")
        }
        
        do {
            //Should fail if content ID has commas.
            let newline = Attachment(filename: "dot.png", content: image, disposition: .attachment, type: .png, contentID: "asdf,asdf")
            try newline.validate()
            XCTFail("Expected error to be thrown when providing a content ID with a commma, but no error was thrown")
        } catch SendGrid.Exception.Mail.invalidContentID(let errorID) {
            XCTAssertEqual(errorID, "asdf,asdf")
        } catch {
            XCTFail("An unexpected error was thrown: \(error)")
        }
        
        do {
            //Should fail if content ID is a blank string.
            let newline = Attachment(filename: "dot.png", content: image, disposition: .attachment, type: .png, contentID: "")
            try newline.validate()
            XCTFail("Expected error to be thrown when providing a blank string for the content ID, but no error was thrown")
        } catch SendGrid.Exception.Mail.invalidContentID(let errorID) {
            XCTAssertEqual(errorID, "")
        } catch {
            XCTFail("An unexpected error was thrown: \(error)")
        }
    }
    
}
