//
//  ViewController.swift
//  Todoey
//
//  Created by Roman Maklakov on 12/3/18.
//  Copyright © 2018 Roman Maklakov. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        guard let colorHex = selectedCategory?.colorHexString else {
            fatalError()
        }
        title = selectedCategory!.name
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller doesn't exist")
        }
        
        guard let newBarColor = UIColor(hexString: colorHex) else {
            fatalError()
        }

        navBar.barTintColor = newBarColor
        searchBar.barTintColor = newBarColor
        navBar.tintColor = ContrastColorOf(newBarColor, returnFlat: true)
        
        if #available(iOS 11.0, *) {
            navBar.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: ContrastColorOf(newBarColor, returnFlat: true)
            ]
        } else {
            // Fallback on earlier versions
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let originalColor = UIColor(hexString: "1D9BF6") else {fatalError() }
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = originalColor
            navigationBar.tintColor = FlatWhite()
            if #available(iOS 11.0, *) {
                navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
            } else {
                // Fallback on earlier versions
            }

        }
    }

    // MARK - Table View Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none;

            if let color = UIColor(hexString: selectedCategory!.colorHexString)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No items added"
        }

        return cell
    }
    
    // MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
//                    realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
            
        }
        tableView.reloadData()
        
//        tableView.deselectRow(at: indexPath, animated: true)
//        self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
    }
    
    // MARK - Add new itmes
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField!
        let alert = UIAlertController(title: "Add new todoye item", message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            
            if let category = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        category.items.append(newItem)
                    }
                } catch {
                    print("Error saving items, \(error)")
                }
                
            }
            
            self.tableView.reloadData()

        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemToDelete)
                }
            } catch {
                print("Error while trying to delete item")
            }

        }
    }
    
    // MARK: NavBar setup methods
    func updateNavBar(withHexCode colorHexCode: String) {
        
    }
}

// MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let newItems = todoItems?
            .filter("title CONTAINS[cd] %@", searchBar.text!)
            .sorted(byKeyPath: "dateCreated", ascending: true)

        
        todoItems = newItems
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
        }
    }
}
