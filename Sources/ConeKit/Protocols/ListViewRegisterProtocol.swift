//
//  ListViewRegisterProtocol.swift
//  MyKit
//
//  Created by HanQi on 2021/3/23.
//

import Foundation
import UIKit

public enum ListViewRegisterViewType {
    case header
    case footer
    case none
}

public protocol ListViewRegisterViewProtocol {
    associatedtype View
    func registerViewNib<View>(_ aClass: View.Type, _ type: ListViewRegisterViewType)
    func registerViewClass<View>(_ aClass: View.Type, _ type: ListViewRegisterViewType)
    func dequeueReusableView<View>(_ aClass: View.Type, _ type: ListViewRegisterViewType, _ indexPath: IndexPath) -> View
}

public protocol ListViewRegisterCellProtocol {
    associatedtype Cell
    func registerCellNib<Cell>(_ aClass: Cell.Type)
    func registerCellClass<Cell>(_ aClass: Cell.Type)
    func dequeueReusableCell<Cell>(_ aClass: Cell.Type, _ indexPath: IndexPath) -> Cell
}  

// Mark: - UITableView
extension UITableView: ListViewRegisterCellProtocol {
    public typealias Cell = UITableViewCell
    
    public func registerCellNib<Cell>(_ aClass: Cell.Type) {
        let name = String(describing: aClass)
        let bundle = Bundle(for: aClass as! AnyClass)
        let nib = UINib(nibName: name, bundle: bundle)
        register(nib, forCellReuseIdentifier: name)
    }
    
    public func registerCellClass<Cell>(_ aClass: Cell.Type) {
        let name = String(describing: aClass)
        register(aClass as? AnyClass, forCellReuseIdentifier: name)
    }
    
    public func dequeueReusableCell<Cell>(_ aClass: Cell.Type, _ indexPath: IndexPath) -> Cell {
        let name = String(describing: aClass)
        guard let cell = dequeueReusableCell(withIdentifier: name,for: indexPath) as? Cell else {
            fatalError("\(name) is not registed")
        }
        return cell
    }
}

extension UITableView: ListViewRegisterViewProtocol {
    public typealias View = UIView
    
    public func registerViewNib<View>(_ aClass: View.Type, _ type: ListViewRegisterViewType = .none) {
        let name = String(describing: aClass)
        let bundle = Bundle(for: aClass as! AnyClass)
        let nib = UINib(nibName: name, bundle: bundle)
        register(nib, forHeaderFooterViewReuseIdentifier: name)
    }
    
    public func registerViewClass<View>(_ aClass: View.Type, _ type: ListViewRegisterViewType = .none) {
        let name = String(describing: aClass)
        register(aClass as? AnyClass, forHeaderFooterViewReuseIdentifier: name)
    }
    
    public func dequeueReusableView<View>(_ aClass: View.Type, _ type: ListViewRegisterViewType = .none, _ indexPath: IndexPath = IndexPath(item: 0, section: 0)) -> View {
        let name = String(describing: aClass)
        guard let cell = dequeueReusableHeaderFooterView(withIdentifier: name) as? View else {
            fatalError("\(name) is not registed")
        }
        return cell
    }
    
}

// Mark: - UICollectionView
extension UICollectionView: ListViewRegisterViewProtocol {
    public typealias View = UICollectionReusableView
    
    public func registerViewNib<View>(_ aClass: View.Type, _ type: ListViewRegisterViewType) {
        let name = String(describing: aClass)
        let bundle = Bundle(for: aClass as! AnyClass)
        let nib = UINib(nibName: name, bundle: bundle)
        if type == .header {
            register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: name)
        } else {
            register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: name)
        }
    }
    
    public func registerViewClass<View>(_ aClass: View.Type, _ type: ListViewRegisterViewType) {
        let name = String(describing: aClass)
        if type == .header {
            register(aClass as? AnyClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: name)
        } else {
            register(aClass as? AnyClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: name)
        }
        
    }
    
    public func dequeueReusableView<View>(_ aClass: View.Type, _ type: ListViewRegisterViewType, _ indexPath: IndexPath) -> View {
        let name = String(describing: aClass)
        if type == .header {
            guard let view = dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: name,
                    for: indexPath) as? View else {
                fatalError("\(name) is not registed")
            }
            return view
        }
        guard let view = dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: name,
                for: indexPath) as? View else {
            fatalError("\(name) is not registed")
        }
        return view
    }
    
}


extension UICollectionView: ListViewRegisterCellProtocol {
    public typealias Cell = UICollectionViewCell
    
    public func registerCellNib<Cell>(_ aClass: Cell.Type) {
        let name = String(describing: aClass)
        let bundle = Bundle(for: aClass as! AnyClass)
        let nib = UINib(nibName: name, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: name)
    }
    
    public func registerCellClass<Cell>(_ aClass: Cell.Type) {
        let name = String(describing: aClass)
        register(aClass as? AnyClass, forCellWithReuseIdentifier: name)
    }
    
    public func dequeueReusableCell<Cell>(_ aClass: Cell.Type, _ indexPath: IndexPath) -> Cell {
        let name = String(describing: aClass)
        guard let cell = dequeueReusableCell(withReuseIdentifier: name,for: indexPath) as? Cell else {
            fatalError("\(name) is not registed")
        }
        return cell
    }
}
