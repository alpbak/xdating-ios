//
//  DialogsNewViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 21.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import SVProgressHUD
import Quickblox
import Parse

class DialogsNewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChatManagerDelegate, QBChatDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    private let chatManager = ChatManager.instance
    private var dialogs: [QBChatDialog] = []
    private var cancel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.register(UINib(nibName: "DialogCellNew", bundle: nil), forCellReuseIdentifier: "DialogCellNew")
        
        print("DialogsNewViewController - viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("DialogsNewViewController - viewWillAppear")
        
        reloadContent()
        
        chatManager.delegate = self
        if QBChat.instance.isConnected == true {
            print("DialogsNewViewController - QBChat.instance.isConnected")
            chatManager.updateStorage()
        }
        else{
            print("DialogsNewViewController - QBChat.instance.isNOT connected")
        }
        
        let tapGestureDelete = UILongPressGestureRecognizer(target: self, action: #selector(tapEdit(_:)))
        tapGestureDelete.minimumPressDuration = 0.3
        tapGestureDelete.delaysTouchesBegan = true
        tableView.addGestureRecognizer(tapGestureDelete)
        
        //MARK: - Reachability
        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            if notConnection == true {
                self?.showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
    }
    
    @objc func tapEdit(_ gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            if let deleteVC = storyboard?.instantiateViewController(withIdentifier: "DialogsSelectionVC") as? DialogsSelectionVC {
                deleteVC.action = ChatActions.Delete
                let navVC = UINavigationController(rootViewController: deleteVC)
                navVC.navigationBar.barTintColor = #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1)
                navVC.navigationBar.barStyle = .black
                navVC.navigationBar.shadowImage = UIImage(named: "navbar-shadow")
                navVC.navigationBar.isTranslucent = false
                navVC.modalPresentationStyle = .fullScreen
                present(navVC, animated: false) {
                    self.tableView.removeGestureRecognizer(gestureReconizer)
                }
            }
        }
    }
    
    @objc func didTapInfo(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: DialogsConstant.infoSegue, sender: sender)
    }
    
    @objc func didTapNewChat(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: DialogsConstant.selectOpponents, sender: sender)
    }
    
    //MARK: - Internal Methods
    private func hasConnectivity() -> Bool {
        
        let status = Reachability.instance.networkConnectionStatus()
        guard status != NetworkConnectionStatus.notConnection else {
            showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            return false
        }
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dialogs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "DialogCellNew"
        var cell: DialogCellNew! = tableView.dequeueReusableCell(withIdentifier: identifier) as? DialogCellNew

        if cell == nil {
            tableView.register(UINib(nibName: "DialogCellNew", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DialogCellNew
        }
                
        let chatDialog = dialogs[indexPath.row]
        let cellModel = DialogTableViewCellModel(dialog: chatDialog)
        cell.setupCell(index: indexPath.row, chatDialog: chatDialog, cellModel: cellModel)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DID SELECT CHAT")
        tableView.deselectRow(at: indexPath, animated: true)
        let dialog = dialogs[indexPath.row]
//        performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_CHAT".localized , sender: dialog.id)
        
        let vc = ChatNewViewController()
        vc.dialogID = dialog.id
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let dialog = dialogs[indexPath.row]
        if dialog.type == .publicGroup {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if Reachability.instance.networkConnectionStatus() == .notConnection {
            showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            return
        }
        
        let dialog = dialogs[indexPath.row]
        if editingStyle != .delete || dialog.type == .publicGroup {
            return
        }
        
        let alertController = UIAlertController(title: "SA_STR_WARNING".localized,
                                                message: "SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG".localized,
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel, handler: nil)
        
        let leaveAction = UIAlertAction(title: "SA_STR_DELETE".localized, style: .default) { (action:UIAlertAction) in
            SVProgressHUD.show(withStatus: "SA_STR_DELETING".localized)
            
            guard let dialogID = dialog.id else {
                SVProgressHUD.dismiss()
                return
            }
            
            if dialog.type == .private {
                self.chatManager.leaveDialog(withID: dialogID)
            } else {
                
                let currentUser = Profile()
                guard currentUser.isFull == true else {
                    return
                }
                // group
                dialog.pullOccupantsIDs = [(NSNumber(value: currentUser.ID)).stringValue]
                
                let message = "\(currentUser.fullName) " + "SA_STR_USER_HAS_LEFT".localized
                // Notifies occupants that user left the dialog.
                self.chatManager.sendLeaveMessage(message, to: dialog, completion: { (error) in
                    if let error = error {
                        debugPrint("[DialogsViewController] sendLeaveMessage error: \(error.localizedDescription)")
                        SVProgressHUD.dismiss()
                        return
                    }
                    self.chatManager.leaveDialog(withID: dialogID)
                })
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(leaveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "SA_STR_DELETE".localized
    }
    
    // MARK: - Helpers
    private func reloadContent() {
        dialogs = chatManager.storage.dialogsSortByUpdatedAt()
        chatManager.storage.setTotalUnreadMessageCount { (unreadMessageCount) in
            self.setUnreadBadge(unreadCount: unreadMessageCount)
        }
        tableView.reloadData()
    }
    
    
    
    func setUnreadBadge(unreadCount:Int){
        if unreadCount == 0 {
            self.tabBarItem.badgeValue = nil
        }
        else{
            self.tabBarItem.badgeValue = "\(unreadCount)"
        }
    }
    
    // MARK: - ChatManagerDelegate
    
    func chatManager(_ chatManager: ChatManager, didUpdateChatDialog chatDialog: QBChatDialog) {
        print("ChatManager, didUpdateChatDialog")
        
        chatManager.storage.setTotalUnreadMessageCount { (unreadMessageCount) in
            self.setUnreadBadge(unreadCount: unreadMessageCount)
        }
        
        reloadContent()
        SVProgressHUD.dismiss()
    }
    
    func chatManager(_ chatManager: ChatManager, didFailUpdateStorage message: String) {
        print("ChatManager, didFailUpdateStorage")
        SVProgressHUD.showError(withStatus: message)
    }
    
    func chatManager(_ chatManager: ChatManager, didUpdateStorage message: String) {
        print("ChatManager, didUpdateStorage")
        reloadContent()
        SVProgressHUD.dismiss()
        QBChat.instance.addDelegate(self)
    }
    
    func chatManagerWillUpdateStorage(_ chatManager: ChatManager) {
        if navigationController?.topViewController == self {
            
        }
    }
    
    
    
    // MARK: QBChatDelegate
    
    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
        print("chatRoomDidReceive")
        chatManager.updateDialog(with: dialogID, with: message)
    }
    
    func chatDidReceive(_ message: QBChatMessage) {
        print("chatDidReceive")
        guard let dialogID = message.dialogID else {
            return
        }
        chatManager.updateDialog(with: dialogID, with: message)
    }
    
    func chatDidReceiveSystemMessage(_ message: QBChatMessage) {
        print("chatDidReceiveSystemMessage")
        guard let dialogID = message.dialogID else {
            return
        }
        if let _ = chatManager.storage.dialog(withID: dialogID) {
            return
        }
        chatManager.updateDialog(with: dialogID, with: message)
    }
    
    func chatServiceChatDidFail(withStreamError error: Error) {
        print("chatServiceChatDidFail")
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
    
    func chatDidAccidentallyDisconnect() {
        print("chatDidAccidentallyDisconnect")
    }
    
    func chatDidNotConnectWithError(_ error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
    
    func chatDidDisconnectWithError(_ error: Error) {
    }
    
    func chatDidConnect() {
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
            SVProgressHUD.showSuccess(withStatus: "SA_STR_CONNECTED".localized)
        }
    }
    
    func chatDidReconnect() {
        SVProgressHUD.show(withStatus: "SA_STR_CONNECTED".localized)
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
            SVProgressHUD.showSuccess(withStatus: "SA_STR_CONNECTED".localized)
        }
    }
}






