import requests, json, urllib.request, os
from bs4 import BeautifulSoup

num_cards = '100'
r = requests.post('http://cf-vanguard.com/en/cardlist/cardsearch', data={'data[CardSearch][show_page_count]':num_cards, 'data[CardSearch][keyword]':'', 'cmd':'search'})
r.encoding = 'utf-8'
soup = BeautifulSoup(r.text)
os.makedirs("cardfaces", exist_ok=True)
with open("cards.json", "w") as file:
    cards = []
    for tr in soup.find(id="searchResult-table").find_all("tr"):
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
            try:
                if not os.path.isfile("cardfaces/"+filename):
                    urllib.request.urlretrieve("http://cf-vanguard.com/en/cardlist/"+str(src), "cardfaces/"+filename)
                card["[Image]"] = filename
            except urllib.error.HTTPError:
                pass

        cards.append(card)
    json.dump(cards, file)
