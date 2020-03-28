//
//  ViewController.swift
//  rssNewsReader
//
//  Created by nuri Lee on 27/03/2020.
//  Copyright © 2020 nuri Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("앱 시작");
        
        //1.3초 후 뉴스 리스트 화면으로 이동
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.performSegue(withIdentifier: "toNaviView", sender: self);
        }
        
    }
    
    
    //화면 전환 함수
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toNaviView" {
            print("다음 화면으로 이동")
        }
     
        
    }
    


}

