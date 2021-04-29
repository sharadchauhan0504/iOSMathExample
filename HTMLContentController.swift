//
//  HTMLContentController.swift
//
//
//  Created by Sharad on 13/01/21.
//

import UIKit
import iosMath

//MARK:- String extension - convert html to NSAttributedString
extension String {
    
    var utfData: Data {
        return Data(utf8)
    }
    
    var attributedHtmlString: NSAttributedString? {
        do {
            return try NSAttributedString(data: utfData, options: [
              .documentType: NSAttributedString.DocumentType.html,
              .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil)
        } catch {
            print("Error:", error)
            return nil
        }
    }
}

//MARK:- NSMutableAttributedString extension - set font
extension NSMutableAttributedString {
    
    func setFontFace(font: UIFont, color: UIColor? = nil) {
        beginEditing()
        self.enumerateAttribute(
            .font,
            in: NSRange(location: 0, length: self.length)
        ) { (value, range, stop) in
            
            if let f = value as? UIFont,
               let newFontDescriptor = f.fontDescriptor
                .withFamily(font.familyName)
                .withSymbolicTraits(f.fontDescriptor.symbolicTraits) {
                
                let newFont = UIFont(
                    descriptor: newFontDescriptor,
                    size: font.pointSize
                )
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
                if let color = color {
                    removeAttribute(
                        .foregroundColor,
                        range: range
                    )
                    addAttribute(
                        .foregroundColor,
                        value: color,
                        range: range
                    )
                }
            }
        }
        endEditing()
    }

}

//MARK:- HTMLContentController
class HTMLContentController: UIViewController {

    let htmlString = """
    <pre>
    <code>
    x = 5;
    y = 6;
    z = x + y;
    </code>
    </pre>
    <br>
    <p><b>This text is bold</b></p>
    <p><i>This text is italic</i></p>
    <p>This is<strong><sub> subscript</sub></strong> and <sup>superscript</sup></p>
     
        <p> Given a right triangle having catheti of length \\((a)\\) resp. \\((b)\\) and a hypotenuse of length \\((c)\\), we have \\([a^2 + b^2 = c^2]\\). This fact is known as the Pythagorean theorem. </p>
        <br>
        <p> \\(\\cos (2\\theta) = \\cos^2 \\theta - \\sin^2 \\theta\\) </p><br>
    <p> \\(sum _{ab\\frac{\\partial af\\frac{sdfas}{45}}{\\partial x}}^{}\\) </p><br>

    <span class="mrow"><span class="mi">t<span class="mi">a<span class="mi">n<span class="mo">(<span class="mfrac"><span class="mn">45<span class="mn">2<span class="mo">)<span class="mo">=<span class="msqrt"><span class="mrow"><span class="mn">2–√<span class="mo">−<span class="mn">1
    <br><br>
    <img src=http://latex.codecogs.com/gif.latex?%5Cbinom%7Bn%7D%7Bk%7D%20%3D%20%5Cfrac%7Bn%21%7D%7Bk%21%28n-k%29%21%7D>
    <br>
    <p> \\(\\lim\\limits_{n\\rightarrow+\\infty}\\left (\\frac{1}{\\sqrt{n}}+3\\right) =? \\) </p>
"""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testHTMLString()
    }

    
    
    private func testHTMLString() {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        if let attributedText = htmlString.attributedHtmlString {
            
            let attributedString = NSMutableAttributedString(attributedString: attributedText)
            attributedString.setFontFace(font: UIFont(name: "Mulish-Regular", size: 16.0)!)
            
            if attributedString.string.contains("\\(") {
                let tempMutableString = NSMutableAttributedString(attributedString: attributedString)
                let pattern = #"\\\((.*?)\\\)"#
                let regex = try! NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
                let testString = attributedString.string
                let stringRange = NSRange(location: 0, length: testString.utf16.count)
                let matches = regex.matches(in: testString, range: stringRange)
                if matches.isEmpty {
                    label.attributedText = attributedString
                } else {
                    for match in matches {
                        for rangeIndex in 1 ..< match.numberOfRanges {
                            let substring = (testString as NSString).substring(with: match.range(at: rangeIndex))
                            let image = imageWithLabel(string: substring)
                            let flip = UIImage(cgImage: image.cgImage!, scale: 2.5, orientation: .downMirrored)
                            let attachment = NSTextAttachment()
                            attachment.image = flip
                            attachment.bounds = CGRect(x: 0, y: -flip.size.height/2 + 5, width: flip.size.width, height: flip.size.height)
                            let replacement = NSAttributedString(attachment: attachment)
                            let finalRange = tempMutableString.string.range(of: "\\(\(substring)\\)", options: .forcedOrdering, range: tempMutableString.string.startIndex..<tempMutableString.string.endIndex, locale: Locale(identifier: "en-US"))
                            tempMutableString.replaceCharacters(in:  NSRange(finalRange!, in: tempMutableString.string), with: replacement)
                            label.attributedText = tempMutableString
                        }
                    }
                }
            } else {
                label.attributedText = attributedString
            }
            
        }
    }
    
    func imageWithLabel(string: String) -> UIImage {
        let label = MTMathUILabel()
        label.latex = string
        //label.font = MTFont().copy(withSize: 20.0)
        label.sizeToFit()
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}
