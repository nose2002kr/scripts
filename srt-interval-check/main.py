import subprocess
from time import sleep

if __name__ == '__main__':
    while True:
        proc = subprocess.run(
            [
              'curl', 'https://etk.srail.kr/hpg/hra/01/selectScheduleList.do?pageId=TK0101010000',
              '-H', 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
              '-H', 'Accept-Language: ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7',
              '-H', 'Cache-Control: max-age=0',
              '-H', 'Connection: keep-alive',
              '-H', 'Content-Type: application/x-www-form-urlencoded',
              '-H', 'Cookie: WMONID=mXsJbfQ7ZcJ; PCID=16673617183864382978061; RC_COLOR=24; JSESSIONID_ETK=F7yZcoLovF56X6GhZxLPWUVBTVbnzv0Y7lps0ScS75JjbX0Bbq1abViyzngjrw81.ZXRrcC9FVEtDT04wMQ==; RC_RESOLUTION=1920*1080',
              '-H', 'Origin: https://etk.srail.kr',
              '-H', 'Referer: https://etk.srail.kr/hpg/hra/01/selectScheduleList.do?pageId=TK0101010000',
              '-H', 'Sec-Fetch-Dest: document',
              '-H', 'Sec-Fetch-Mode: navigate',
              '-H', 'Sec-Fetch-Site: same-origin',
              '-H', 'Sec-Fetch-User: ?1',
              '-H', 'Upgrade-Insecure-Requests: 1',
              '-H', 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36',
              '-H', 'sec-ch-ua: "Chromium";v="106", "Google Chrome";v="106", "Not;A=Brand";v="99"',
              '-H', 'sec-ch-ua-mobile: ?0',
              '-H', 'sec-ch-ua-platform: "Windows"',
              '--data-raw', 'dptRsStnCd=0551&arvRsStnCd=0502&stlbTrnClsfCd=05&psgNum=1&seatAttCd=015&isRequest=Y&dptRsStnCdNm=%EC%88%98%EC%84%9C&arvRsStnCdNm=%EC%B2%9C%EC%95%88%EC%95%84%EC%82%B0&dptDt=20221103&dptTm=000000&chtnDvCd=1&psgInfoPerPrnb1=1&psgInfoPerPrnb5=0&psgInfoPerPrnb4=0&psgInfoPerPrnb2=0&psgInfoPerPrnb3=0&locSeatAttCd1=000&rqSeatAttCd1=015&trnGpCd=109',
              #'--compresse'
             #'--compressed'
             ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        cout = proc.stdout
        coutstr = cout.decode('UTF-8')
        if coutstr.find('레이어 열기') == -1:
            for i in range(0,10):
                print('####### WARNING!!! ##########')

        if coutstr[coutstr.find('09:39'):coutstr.find('09:40')].find('예약하기') != -1:
            for i in range(0, 10):
                print('###### FoUND! !! ########### ')

        print ('running....')

        sleep(2)