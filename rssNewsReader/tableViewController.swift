//
//  tableViewController.swift
//  rssNewsReader
//
//  Created by nuri Lee on 27/03/2020.
//  Copyright © 2020 nuri Lee. All rights reserved.
//

import UIKit

import SDWebImage


class tableViewController: UIViewController, XMLParserDelegate{
    

    @IBOutlet weak var myTableView: UITableView!
    
    
    
    var myFeed : NSArray = []
    var myFeedThumbnailUrl : [String] = [String]();
    var feedImgs: [AnyObject] = []
    var url: URL!
    
    var myImage = UIImage();
    
    //테이블 당기면 새로고침 컨트롤
    var refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //테이블 셀 높이 유동적
        myTableView.rowHeight = UITableView.automaticDimension
        
        
        //테이블뷰 당기면 새로고침 추가하기
        self.myTableView.refreshControl = self.refreshControl;
        self.refreshControl.addTarget(self, action: #selector(self.didRefresh), for: UIControl.Event.valueChanged)
        
        loadData();
    }
    
    //refreshControl
    @objc func didRefresh(){
        self.myTableView.isUserInteractionEnabled = false;
        loadRss(url);
    }

 
    
    //화면 전환 함수
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailView" {
            
            //선택셀 태그 가져오기
            let indexPath = myTableView.indexPathForSelectedRow ?? IndexPath();
            let selectCellTag = myTableView.cellForRow(at: indexPath)?.tag ?? 0
            //print(selectCellTag)
            
            //선택한 셀의 뉴스 url주소
            let news_link = (self.myFeed.object(at: selectCellTag) as AnyObject).object(forKey: "link") as! String
            //print(news_link);
            
            //선택한 셀의 뉴스 url주소
            let news_title = (self.myFeed.object(at: selectCellTag) as AnyObject).object(forKey: "title") as! String
            
            //선택한 셀의 본문 내용
            let news_description = (myFeed.object(at: indexPath.row) as AnyObject).object(forKey: "description") as? String//html태그 제거
            let news_description_non_tag = news_description?.withoutHtmlTags.replacingOccurrences(of: "&nbsp;", with: " "); //nbsp 제거
            let news_description_non_tag_bug = news_description_non_tag?.replacingOccurrences(of: "[^\\w\\sㄱ-ㅎ가-힣ㅏ-ㅣ]|[_]", with: "", options: .regularExpression)//특수문자 제거 ( 띄어쓰기는 제거 안됨 )
            
            //키워드 많은 순으로 정렬된 딕셔너리 배열
            let keyWordSortedDrictionary : [(key: String, value: Int)] = self.dictionaryWordCountCheck( str : news_description_non_tag_bug!);
            
            //다음 화면에 파라미터 넘겨주기
            let secondVC = segue.destination as! detailViewController
            secondVC.news_url = news_link;
            secondVC.news_title = news_title;
            secondVC.keyWordSortedDrictionary = keyWordSortedDrictionary;
            
            
        }//if
        
        
    }
    
    

//MARK: - create func
    
    //loadData
    func loadData() {
        
        self.myTableView.isHidden = true;
        
        //url = URL(string: "http://feeds.skynews.com/feeds/rss/technology.xml")!
        url = URL(string: "https://news.google.com/rss?hl=ko&gl=KR&ceid=KR:ko")!

        loadRss(url);
        
        
    }

    //RSS Load
    func loadRss(_ data: URL) {
        
        //초기화
        myFeed = []
        myFeedThumbnailUrl = [String]();
        feedImgs = []
        
        

        // XmlParserManager instance/object/variable.
        let myParser : XmlParserManager = XmlParserManager().initWithURL(data) as! XmlParserManager

        // Put feed in array.
        feedImgs = myParser.img as [AnyObject]
        myFeed = myParser.feeds
        
        
        print("table view 초기화");
        print(myParser.feeds.count);
        
        //썸네일 주소 배열 초기화
        myFeedThumbnailUrl = [String]( repeating: "0", count: myParser.feeds.count)

        
        
        //뉴스 섬네일 주소 알아오기
        var tableLoadEnable = true;
        DispatchQueue.main.async() {

            //기본 구글 썸네일
            let initThumbnailUrl = "https://lh3.googleusercontent.com/J6_coFbogxhRI9iM864NL_liGXvsQp2AupsKei7z0cNNfDvGUmWUy20nuUhkREQyrpY4bEeIBuc=w300";
            
            //기사 주소를 통한 og:image 주소 가져오기
            for i in 0..<myParser.feeds.count {

                let news_link2 = (self.myFeed.object(at: i) as AnyObject).object(forKey: "link") as? String
                //let news_link2 = "https://news.google.com/?hl=ko&gl=KR&ceid=KR:ko";
                let news_link_url : URL = URL(string: news_link2!)!;


                    OpenGraph.fetch(url: news_link_url) { result in
                
                        switch result {
                        case .success(let og):
                            //print(og[.title]!) // => og:title of the web site
                            //print(og[.type]!)  // => og:type of the web site
                            self.myFeedThumbnailUrl[i] = og[.image] ?? initThumbnailUrl;
                            //print(og[.image] ?? initThumbnailUrl) // => og:image of the web site
                            //print(og[.url]!)   // => og:url of the web site
                        case .failure(let error):
                       
                       self.myFeedThumbnailUrl[i] = initThumbnailUrl;
                            
                        
                            //구글 기본 이미지
                            print(error)
                        }
                        
                        
                        //썸네일 배열에 다 추가 되었는지 체크
                        for i in self.myFeedThumbnailUrl
                        {
                            //아직 채워지지 않은 배열이 있을 경우
                            if( i == "0")
                            {
                                tableLoadEnable = false;
                                break;
                            }else{
                                tableLoadEnable = true;
                            }
                        }
                        
                        //테이블 리로드 조건
                        if(tableLoadEnable)
                        {

                            tableLoadEnable = false;
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.refreshControl.endRefreshing();
                                self.myTableView.isUserInteractionEnabled = true;
                            }
                            print("끝");
                            
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.myTableView.isHidden = false;
                                self.tableReloaddd();
                            }
                            
                        }else{
                            tableLoadEnable = true;
                            //print("안끝");
                        }//if 테이블 리로드 조건
                        
                    }
                
                


            }//for

        }


        
    }//func
    
    
    
    //테이블 새로고침
    func tableReloaddd()
    {
        DispatchQueue.main.async() {
            self.myTableView.reloadData();
        }
        
    }
    
    
    
    
    //디렉셔너리 문자 빈도수 체크하기 프린트
    func dictionaryPrint(dict : [String:Int])
    {
        print();
        print("<키워드 빈도수>");
        for e in dict {

            print(e)
            
            //print(e.key);
        }
    }
    //디렉셔너리 문자 빈도수 체크하기 프린트
    func dictionarySortedPrint(dict : [(key: String, value: Int)])
    {
        print();
        print("<키워드 우선순위 정렬>");
        for e in dict {

            print(e)
            
            //print(e.key);
        }
        print();
        print();
    }
    
    
    //디렉셔너리 문자 빈도수 체크하기 함수
    func dictionaryWordCountCheck(str : String) -> [(key: String, value: Int)]
    {
        //문자 단어 빈도수 체크하기
        //let text = "다라 마바 사바 가나 나다 나다 가 가 a aa b bb cc dd d 나 다 차타 하타 하타 차타 다라 다라 다라 다라 다라 마바 바바 바바 가나 다깅 다깅";
        let text = str;
        var dict : [String:Int] = [:];

        let words = text.components(separatedBy: " ")
        for word in words {

          //문자가 2글자 이상인것
          if(word.count >= 2)
          {
              
              // if word doesn't exist in dictionary
              if dict[word] == nil {
                  // add word with value 1
                  dict[word] = 1
              }
              else {
                  // if exists, increment value
                  dict[word] = dict[word]! + 1
              }
          }//if
        }

        
        //print
        dictionaryPrint(dict: dict)

        
        //딕셔너리 string:int 배열 value값에 따른 내림차순 정렬 and key값 가나다순 정렬 (정렬 이중 조건 : 1. value, 2. key)
        let byValue = {
          (elem1:(key: String, val: Int), elem2:(key: String, val: Int))->Bool in
          
          if (elem1.val == elem2.val) {
              return elem1.key < elem2.key
          } else {
            return elem1.val > elem2.val
          }
          
        }
        let sortedDict = dict.sorted(by: byValue);

        
        //print
        dictionarySortedPrint(dict: sortedDict);

        
        return sortedDict
    }


}



//MARK: - table

extension tableViewController: UITableViewDelegate, UITableViewDataSource{
    
    //테이블 셀 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFeed.count;
    }
    
    
    //테이블 셀 정의
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! tableCell;
        cell.tag = indexPath.row;

        
        
        //rss 뉴스 title
        let news_title = (myFeed.object(at: indexPath.row) as AnyObject).object(forKey: "title") as? String
        //rss 뉴스 내용
        let news_description = (myFeed.object(at: indexPath.row) as AnyObject).object(forKey: "description") as? String
 
        
        //섬네일 이미지 유무에 따라서 SDWebImage(캐시활용) 이미지 셀 적용
        if indexPath.row >= 0 && indexPath.row < myFeedThumbnailUrl.count {
            //print("값 있슈");
            cell.thumbnail.sd_setImage(with: URL(string: self.myFeedThumbnailUrl[indexPath.row]), placeholderImage: nil, completed: { (image, error, cacheType, imageURL) in
                //print("뿡");
            })
        }else{
            //print("값 에러");
            cell.thumbnail.sd_setImage(with: URL(string: "https://lh3.googleusercontent.com/J6_coFbogxhRI9iM864NL_liGXvsQp2AupsKei7z0cNNfDvGUmWUy20nuUhkREQyrpY4bEeIBuc=w300"), placeholderImage: nil, completed: { (image, error, cacheType, imageURL) in
                //print("뿡");
            })
        }
        
        
        
        
        

        //뉴스 타이틀 적용
        cell.titleLabel.text = news_title;
        
        
        //본문 내용 태그 제거 하기
        let news_description_non_tag = news_description?.withoutHtmlTags.replacingOccurrences(of: "&nbsp;", with: " ");
        cell.bodyLabel.text = news_description_non_tag ?? "";
        let news_description_non_tag_bug = news_description_non_tag?.replacingOccurrences(of: "[^\\w\\sㄱ-ㅎ가-힣ㅏ-ㅣ]|[_]", with: "", options: .regularExpression)//특수문자 제거 ( 띄어쓰기는 제거 안됨 )

        
        
        //키워드 빈도수 적용 (3개까지)
        DispatchQueue.main.async() {
            
            //키워드 라벨 히든
            for i in 0..<3
            {
                cell.keyWordLabelList[i].isHidden = true;
            }
            
            //키워드 많은 순으로 정렬된 딕셔너리 배열
            let keyWordSortedDrictionary : [(key: String, value: Int)] = self.dictionaryWordCountCheck( str : news_description_non_tag_bug!);
            
            var keyWordCount = 0;
            for i in keyWordSortedDrictionary
            {
                cell.keyWordLabelList[keyWordCount].isHidden = false;
                cell.keyWordLabelList[keyWordCount].text = i.key
                keyWordCount += 1;
                
                //3개 이상은 필요 X
                if ( keyWordCount >= 3 )
                {
                    break;
                }
            }
        }//sync
        
        
        
        return cell
    }
    
    
    //테이블 셀 height 동적 관리
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    
}





//MARK: - other extenstion


//url 이미지 다운로드
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}


//html 태그 삭제 함수
extension String {
    var withoutHtmlTags: String {
      return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}



