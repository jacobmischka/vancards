import requests, json, urllib.request, os, socket
from bs4 import BeautifulSoup

num_cards = '100'
r = requests.post('http://cf-vanguard.com/en/cardlist/cardsearch', data={'data[CardSearch][show_page_count]':num_cards, 'data[CardSearch][keyword]':'', 'cmd':'search'})
r.encoding = 'utf-8'
soup = BeautifulSoup(r.text)
trs = soup.find(id="searchResult-table").find_all("tr")
os.makedirs("cardfaces", exist_ok=True)
with open("cards.json", "w") as file:
    cards = []
    for tr in trs:
        card = {}
        td = tr.find("td")
        for span in td.find_all("span"):
            if span.get("class") == ["unit"]:
                if span.string:
                    words = str(span.string).split(": ")
                    card[words[0]] = words[1]
            else:
                if "[Name]" not in card:
                    card["[Name]"] = span.string
                elif "[Number]" not in card:
                    card["[Number]"] = span.string
                else:
                    card["[Text]"] = span.string

        src = tr.find("th").find("img")['src']
        if str(src).endswith(".jpg"):
            filename = str(card["[Number]"]).replace("/", "-")+".jpg"
            attempts = 3
            while not os.path.isfile("cardfaces/"+filename):
                try:
                    with open("cardfaces/"+filename, "wb") as img:
                        img.write(urllib.request.urlopen("http://cf-vanguard.com/en/cardlist/"+str(src), None, 10).read())
                    card["[Image]"] = filename
                except socket.timeout:
                    attempts -= 1
                    print("timeout (10s): http://cf-vanguard.com/en/cardlist/"+str(src),)
                    if attempts > 0:
                        print("retrying...")
                    else:
                        break
                except (urllib.error.HTTPError, urllib.error.URLError):
                    print("error downloading: http://cf-vanguard.com/en/cardlist/"+str(src))
                    break

        cards.append(card)
        print(str(len(cards))+" / "+str(len(trs)))
    json.dump(cards, file)
