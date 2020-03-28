//
//  detailViewController.swift
//  rssNewsReader
//
//  Created by nuri Lee on 28/03/2020.
//  Copyright © 2020 nuri Lee. All rights reserved.
//
import UIKit
import WebKit

class detailViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    
    //초기 변수
    var news_url : String = String();
    var news_title : String = String();
    var keyWordSortedDrictionary : [(key: String, value: Int)] = [(key: String, value: Int)]();

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var keyWordLabelList: [DesignableLabel]!

    
    @IBOutlet weak var myWebView: WKWebView!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
 
    
    //didLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        print(news_url);
        
        //제목 적용
        titleLabel.text = news_title;
        
        
        //키워드 화면 적용
        DispatchQueue.main.async() {
            //키워드 라벨 히든
            for i in 0..<3
            {
                self.keyWordLabelList[i].isHidden = true;
            }

            
            var keyWordCount = 0;
            for i in self.keyWordSortedDrictionary
            {
                self.keyWordLabelList[keyWordCount].isHidden = false;
                self.keyWordLabelList[keyWordCount].text = i.key
                keyWordCount += 1;
                
                //3개 이상은 필요 X
                if ( keyWordCount >= 3 )
                {
                    break;
                }
            }
        }//sync
        

              
        //웹뷰 적용
        let myUrl = news_url;
        let url = URL(string: myUrl)
        let request = URLRequest(url: url!)
        myWebView.load(request)
        self.myWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil) //webView handler
        
    }//didLoad
    
    
//MARK: - webView
    
    //webView status
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "loading" {
            
            if myWebView.isLoading {
                
                myActivityIndicator.startAnimating()
                myActivityIndicator.isHidden = false
                
            }else {
                
                myActivityIndicator.stopAnimating()
                myActivityIndicator.isHidden = true
                
            }
            
        }
        
    }


}
