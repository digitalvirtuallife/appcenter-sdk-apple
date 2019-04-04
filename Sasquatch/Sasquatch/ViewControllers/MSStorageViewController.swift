// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import UIKit

class MSStorageViewController: UITableViewController {

  enum StorageType: String {
    case App = "App"
    case User = "User"

    static let allValues = [App, User]
  }
  var identitySignIn = false
  static var AppDocuments = ["App1", "App2"]
  static var UserDocuments = ["User1", "User2", "User3"]
  static var AppDocumentContent = ["property1" : "property 1 string", "property2": 11] as [String : Any]
  static var UserDocumentsContent = ["property1": "property 1 string", "property2": 42, "property3": true] as [String : Any]

  private var storageTypePicker: MSEnumPicker<StorageType>?
  private var storageType = "App"

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.setEditing(true, animated: false)
    tableView.allowsSelectionDuringEditing = true
    identitySignIn = UserDefaults.standard.bool(forKey: "identitySignIn")
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 1 {
      return "Storage Type"
    } else if section == 2 {
      if self.storageType == StorageType.User.rawValue && identitySignIn {
        return "User Documents List"
      } else if self.storageType == StorageType.App.rawValue {
        return "App Document List"
      }
    }
    return nil
  }
  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == 1 && self.storageType == StorageType.User.rawValue && !identitySignIn {
      return "Please sign in to Identity firstly"
    }
    return nil
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 2 {
      if self.storageType == StorageType.App.rawValue {
        return MSStorageViewController.AppDocuments.count
      } else if self.storageType == StorageType.User.rawValue {
        if identitySignIn {
          return MSStorageViewController.UserDocuments.count + 1
        } else {
          return 0
        }
      }
    }
    return 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cellIdentifier = "back"
    if indexPath.section == 1 {
      cellIdentifier = "storagetype"
    } else if indexPath.section == 2 {
      cellIdentifier = "document"
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    if indexPath.section == 0 {
      let backButton: UIButton? = cell.getSubview()
      backButton?.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
    } else if indexPath.section == 1 {
      let storageTypeField: UITextField? = cell.getSubview()
      self.storageTypePicker = MSEnumPicker<StorageType> (
        textField: storageTypeField,
        allValues: StorageType.allValues,
        onChange: { index in
          self.storageType = (storageTypeField?.text)!
          self.tableView.reloadSections([2], with: .none)
        }
      )
      storageTypeField?.delegate = self.storageTypePicker
      storageTypeField?.tintColor = UIColor.clear
    } else if indexPath.section == 2 {
      if self.storageType == StorageType.App.rawValue {
        cell.textLabel?.text = MSStorageViewController.AppDocuments[indexPath.row]
      } else if self.storageType == StorageType.User.rawValue {
        if indexPath.row == 0 {
          cell.textLabel?.text = "Add document"
        } else {
          cell.textLabel?.text = MSStorageViewController.UserDocuments[indexPath.row - 1]
        }
      }
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let cell = tableView.cellForRow(at: indexPath)
    if isInsertRow(indexPath) {
      self.performSegue(withIdentifier: "ShowDocumentDetails", sender: "")
    } else if indexPath.section == 2 {
      self.performSegue(withIdentifier: "ShowDocumentDetails", sender: cell?.textLabel?.text)
    }
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    if indexPath.section == 2 && self.storageType == StorageType.User.rawValue {
      return true
    }
    return false
  }

  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    if isInsertRow(indexPath) {
      return .insert
    } else if indexPath.section == 2 && self.storageType == StorageType.User.rawValue {
      return .delete
    }
    return .none
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      MSStorageViewController.UserDocuments.remove(at: indexPath.row - 1)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    } else if editingStyle == .insert {
      self.performSegue(withIdentifier: "ShowDocumentDetails", sender: "")
    }
  }

  func isInsertRow(_ indexPath: IndexPath) -> Bool {
    return self.storageType == StorageType.User.rawValue && indexPath.section == 2 && indexPath.row == 0
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowDocumentDetails" {
      let documentDetailsController = segue.destination as! MSDocumentDetailsViewController
      documentDetailsController.docmentType = self.storageType
      documentDetailsController.documentId = sender as! String
      if self.storageType == StorageType.App.rawValue {
        documentDetailsController.documentContent = MSStorageViewController.AppDocumentContent
      } else {
        documentDetailsController.documentContent = MSStorageViewController.UserDocumentsContent
      }
    }
  }

  func backButtonClicked (_ sender: Any) {
    self.presentingViewController?.dismiss(animated: true, completion: nil)
  }
}
