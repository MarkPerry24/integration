//
//  AutoCompleteTextField.swift
//  AutoComplete
//
//  Created by Paulius on 09/07/2019.
//  Copyright © 2019 Paulius. All rights reserved.
//

import UIKit
import os

class AutoCompleteTextField: UITextField, UITableViewDelegate, UITableViewDataSource
{
        
    private var dataList : [String] = [String]()
    private var tableView: UITableView?
    var completeType : String = "" // Available types are: names, companies, first_names, last_names, emails, addresses, colors
	var APIKey : String = "iSkwEtRMxzOFzWwoy8GEvsL7DMlpn94Uffrg8ETYMOlrsspEZI7Ck_ElqvevdIxz"
    private var dataTask : URLSessionDataTask?
    private let defaultSession = URLSession(configuration: .default)
    lazy private var debounceFilter = debounce(interval: 200, queue: DispatchQueue.main, action: filter)
    
    open override func willMove(toWindow newWindow: UIWindow?)
    {
        super.willMove(toWindow: newWindow)
        tableView?.removeFromSuperview()
    }
    
    override open func willMove(toSuperview newSuperview: UIView?)
    {
        super.willMove(toSuperview: newSuperview)
        
        self.addTarget(self, action: #selector(AutoCompleteTextField.textFieldDidChange), for: .editingChanged)
    }
    
    override open func layoutSubviews()
    {
        super.layoutSubviews()
        buildSearchTableView()
    }
    
    @objc open func textFieldDidChange()
    {
        if(self.text?.count == 0)
        {
            dataList = []
            tableView?.reloadData()
            tableView?.isHidden = true
        }
        debounceFilter()
        updateSearchTableView()
        tableView?.isHidden = false
    }
    
    func debounce(interval: Int, queue: DispatchQueue, action: @escaping (() -> Void)) -> () -> Void {
        var lastTimeFire = DispatchTime.now()
        let dispatchDelay = DispatchTimeInterval.microseconds(interval)
        
        return {
            lastTimeFire = DispatchTime.now()
            let dispatchTime: DispatchTime = DispatchTime.now() + dispatchDelay
            
            queue.asyncAfter(deadline: dispatchTime){
                let when: DispatchTime = lastTimeFire + dispatchDelay
                let now = DispatchTime.now()
                
                if now.rawValue >= when.rawValue
                {
                    action()
                }
            }
        }
    }
    
    fileprivate func filter()
    {
        dataTask?.cancel();
        
        if var urlComponents = URLComponents(string: "https://api.fillaware.com/v1/suggest/\(completeType)")
        {
            urlComponents.query = "q=\(self.text!)&key=\(APIKey)"
            
            guard let url = urlComponents.url else { return }
            
            dataTask = defaultSession.dataTask(with: url) { data, response, error in defer {self.dataTask = nil}
                if let error = error
                {
                    print("DataTask failed with request: \(error.localizedDescription)")
                }
                else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200
                    {
                        do
                        {
                            let jsonData = try JSONSerialization.jsonObject(with: data) as! [String]
                            self.dataList = jsonData
                        }
                        catch
                        {
                            print("Error happened: \(error))")
                        }
                    }
                }
        }
        
        dataTask?.resume();
        
        
        tableView?.reloadData()
    }
    
    func buildSearchTableView() {
        
        if let tableView = tableView {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AutoCompleteTextFieldCell")
            tableView.delegate = self
            tableView.dataSource = self
            self.window?.addSubview(tableView)
            
        } else {
            tableView = UITableView(frame: CGRect.zero)
        }
        
        updateSearchTableView()
    }
    
    func updateSearchTableView() {
        
        if let tableView = tableView {
            superview?.bringSubviewToFront(tableView)
            var tableHeight: CGFloat = 0
            tableHeight = tableView.contentSize.height
            
            if tableHeight < tableView.contentSize.height {
                tableHeight -= 10
            }
            
            var tableViewFrame = CGRect(x: 0, y: 0, width: frame.size.width - 4, height: tableHeight)
            tableViewFrame.origin = self.convert(tableViewFrame.origin, to: nil)
            tableViewFrame.origin.x += 2
            tableViewFrame.origin.y += frame.size.height + 2
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.tableView?.frame = tableViewFrame
            })
            
            tableView.layer.masksToBounds = true
            tableView.separatorInset = UIEdgeInsets.zero
            tableView.layer.cornerRadius = 5.0
            tableView.separatorColor = UIColor.lightGray
            tableView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
            
            if self.isFirstResponder {
                superview?.bringSubviewToFront(self)
            }
            
            tableView.reloadData()
        }
    }
    
    
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteTextFieldCell", for: indexPath) as UITableViewCell
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.attributedText = NSAttributedString(string: dataList[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= dataList.count
        {
            tableView.isHidden = true
            return
        }
        self.text = dataList[indexPath.row]
        tableView.isHidden = true
        self.endEditing(true)
    }
}
