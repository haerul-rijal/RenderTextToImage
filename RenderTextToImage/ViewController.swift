//
//  ViewController.swift
//  RenderTextToImage
//
//  Created by haerul.rijal on 18/01/23.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport
import RxCocoa
import RxCocoa_Texture
import RxSwift

class ViewController: DisplayNodeViewController {
    
    private let spacer: ASDisplayNode = {
        let node = ASDisplayNode()
        node.style.height = ASDimensionMake(1)
        node.style.width = ASDimensionMake("100%")
        node.backgroundColor = .gray
        return node
    }()
    
    private let titleLabel = ASTextNode2()
    private let imageDescription = ASTextNode2()
    private let previewimageDescription = ASTextNode2()
    private let textToRenderNode: ASEditableTextNode = {
        let node = ASEditableTextNode()
        let height: CGFloat = 36
        let font = UIFont.systemFont(ofSize: 14)
        let topPadding = (height - (font.lineHeight))/2
        node.textContainerInset = UIEdgeInsets(top: topPadding, left: 16, bottom: 4, right: 16)
        node.textView.font = font
        node.textView.textContainer.maximumNumberOfLines = 2
        node.textView.autocapitalizationType = .none
        node.textView.autocorrectionType = .no
        node.style.height = ASDimensionMake(height)
        node.attributedPlaceholderText = NSAttributedString(string: "Enter Text", attributes: [
            NSAttributedString.Key.font: font as Any,
            NSAttributedString.Key.foregroundColor : UIColor.gray
        ])
        return node
    }()
    
    private let selectButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.style.height = ASDimensionMake(36)
        node.style.width = ASDimensionMake("100%")
        node.backgroundColor = .pink
        node.setTitle("Select Image", with: nil, with: .white, for: .normal)
        return node
    }()
    
    private let renderButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.style.height = ASDimensionMake(40)
        node.style.width = ASDimensionMake("100%")
        node.backgroundColor = .lightBlue
        node.setTitle("Render With Text", with: nil, with: .white, for: .normal)
        return node
    }()
    
    
    private let saveButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.style.height = ASDimensionMake(40)
        node.style.width = ASDimensionMake("100%")
        node.backgroundColor = .teal
        node.setTitle("Save image", with: nil, with: .white, for: .normal)
        return node
    }()
    
    private let imageNode: ASImageNode = {
        let node = ASImageNode()
        node.contentMode = .scaleAspectFit
        node.backgroundColor = .grayBackground
        node.needsDisplayOnBoundsChange = true
        node.style.height = ASDimensionMake(140)
        node.style.width = ASDimensionMake("100%")
        return node
    }()
    
    private let previewImageNode: ASImageNode = {
        let node = ASImageNode()
        node.contentMode = .scaleAspectFit
        node.backgroundColor = .grayBackground
        node.style.height = ASDimensionMake(220)
        node.style.width = ASDimensionMake("100%")
        node.needsDisplayOnBoundsChange = true
        node.forceUpscaling = true
        return node
    }()
    
    private let textImageNode: ASImageNode = {
        let node = ASImageNode()
        node.contentMode = .scaleAspectFit
        node.needsDisplayOnBoundsChange = true
        node.forceUpscaling = true
        node.style.height = ASDimensionMake(140)
        node.style.width = ASDimensionMake("100%")
        return node
    }()
    
    private let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        node.automaticallyManagesSubnodes = true
        node.automaticallyRelayoutOnSafeAreaChanges = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        node.backgroundColor = .white
        let documentsDirectory = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
        print(documentsDirectory.absoluteURL)
        setupNode()
        setupAction()
    }

    
    private func setupNode() {
        let borderColor = UIColor.gray.cgColor
        textToRenderNode.cornerRadius = 8
        textToRenderNode.borderWidth = 1
        textToRenderNode.borderColor = borderColor
        titleLabel.attributedText = NSAttributedString(string: "Text To Render")
        imageNode.borderWidth = 1
        imageNode.borderColor = borderColor
        previewImageNode.borderWidth = 1
        previewImageNode.borderColor = borderColor
        textToRenderNode.attributedText = NSAttributedString(string: "Tulisan ini panjang sekali sehingga harus pindah baris")
    }
    
    private func setupAction() {
        
        textImageNode.rx.tap.asDriver()
            .drive { _ in
                print("tapped Image")
            }.disposed(by: self.disposeBag)
        
        selectButtonNode.rx.tap.asDriver()
            .drive { [weak self] _ in
                self?.showActionSheet()
            }.disposed(by: self.disposeBag)
        
        renderButtonNode.rx.tap.asDriver()
            .drive { [weak self] _ in
                self?.applyTextOnImage()
            }.disposed(by: self.disposeBag)
        
        saveButtonNode.rx.tap.asDriver()
            .drive { [weak self] _ in
                self?.saveToDisk()
            }.disposed(by: self.disposeBag)
    }
    
    private func saveToDisk() {
        guard let image =  imageNode.image else { return }
        guard let flattenImage = TextRenderer.flattenTextImage(text: textToRenderNode.textView.text, configuration: .defaultConfig, with: image) else { return }
        saveImageToDocumentDirectory(image: flattenImage)
    }
    
    func saveImageToDocumentDirectory(image: UIImage) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "result.jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            if FileManager.default.isDeletableFile(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                } catch {
                    print("error saving file:", error)
                    return
                }
            }
        }
        if let data = image.jpegData(compressionQuality: 1),!FileManager.default.fileExists(atPath: fileURL.path){
            do {
                try data.write(to: fileURL)
                print("file saved")
                print(fileURL)
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    private func applyTextOnImage() {
        guard let image = imageNode.image else { return }
        let previewImageRect = image.size.rectThatFits(in: previewImageNode.frame)
        let scaledImage = image.scalePreservingAspectRatio(targetSize: previewImageRect.size)
        let scaledImageRect = CGRect(origin: .zero, size: scaledImage.size)
        let textImage = TextRenderer.createImageText(text: textToRenderNode.textView.text, configuration: .defaultConfig, rect: scaledImageRect)
        previewImageNode.image = image
        textImageNode.image = textImage
    }
    
    private func showActionSheet() {
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        let image1Action: UIAlertAction = UIAlertAction(title: ImageType.img4288x2848.dimensions, style: .default) { action -> Void in
            self.setImage(imageType: .img4288x2848)
        }
        let image2Action: UIAlertAction = UIAlertAction(title: ImageType.img2048x1360.dimensions, style: .default) { action -> Void in
            self.setImage(imageType: .img2048x1360)
        }
        let image3Action: UIAlertAction = UIAlertAction(title: ImageType.img1024x680.dimensions, style: .default) { action -> Void in
            self.setImage(imageType: .img1024x680)
        }
        let image4Action: UIAlertAction = UIAlertAction(title: ImageType.img256x170.dimensions, style: .default) { action -> Void in
            self.setImage(imageType: .img256x170)
        }
        let image5Action: UIAlertAction = UIAlertAction(title: ImageType.img128x85.dimensions, style: .default) { action -> Void in
            self.setImage(imageType: .img128x85)
        }
        let image6Action: UIAlertAction = UIAlertAction(title: ImageType.img24x16.dimensions, style: .default) { action -> Void in
            self.setImage(imageType: .img24x16)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        // add actions
        actionSheetController.addAction(image1Action)
        actionSheetController.addAction(image2Action)
        actionSheetController.addAction(image3Action)
        actionSheetController.addAction(image4Action)
        actionSheetController.addAction(image5Action)
        actionSheetController.addAction(image6Action)
        actionSheetController.addAction(cancelAction)
        
        actionSheetController.popoverPresentationController?.sourceView = node.view
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    private func setImage(imageType: ImageType) {
        imageNode.image = imageType.image
        let dimensions = "Image Size:\n" + String(describing: imageType.originalSize)
        imageDescription.attributedText = NSAttributedString(string: dimensions)
        node.setNeedsLayout()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout(spacing: 8) {
                titleLabel
                textToRenderNode
                HStackLayout(spacing: 8) {
                    VStackLayout(spacing: 8) {
                        imageNode
                        selectButtonNode
                    }
                        .flexBasis(fraction: 0.60)
                    imageDescription
                        .flexBasis(fraction: 0.38)
                }
                spacer
                renderButtonNode
                CenterLayout {
                    previewImageNode
                        .overlay(textImageNode)
                }
                ASDisplayNode()
                saveButtonNode
            }
            .padding(.horizontal, 16)
            .padding(.top, 32)
            .padding(.vertical, 24)
        }
    }
}


