import requests, json, urllib.request, os, socket, atexit
from bs4 import BeautifulSoup

cards = []

def main():
	atexit.register(save_cards)

	num_cards = '10000'
	r = requests.post('http://cf-vanguard.com/en/cardlist/cardsearch', data={'data[CardSearch][show_page_count]':num_cards, 'data[CardSearch][keyword]':'', 'cmd':'search'})
	r.encoding = 'utf-8'
	soup = BeautifulSoup(r.text, 'html.parser')
	trs = soup.find(id="searchResult-table").find_all("tr")
	os.makedirs("src/cardfaces", exist_ok=True)
	for tr in trs:
		card = {}
		td = tr.find("td")
		for span in td.find_all("span"):
			if span.get("class") == ["unit"]:
				if span.string:
					if span.find("span"):
						string = span.find("span").string
					else:
						string = span.string
					words = str(string).split(": ")
					if words[1] != "-":
						card[words[0]] = words[1]
				else:
					if span.text == "[Nation]: ":
						src = span.find("img")["src"]
						card["[Nation]"] = src[src.find("co_")+3:src.rfind(".")]
					elif span.text == "[Skill Icon]: ":
						src = span.find("img")["src"]
						card["[Skill]"] = src[src.find("sk_")+3:src.rfind(".")]
					elif "[Trigger]" in span.text:
						src = span.find("img")["src"]
						card["[Trigger]"] = src[src.find("tr_")+3:src.rfind(".")]

			else:
				text = ' '.join(span.stripped_strings)
				if "[Race]" in text or "[Clan]" in text:
					words = str(text).split(": ")
					if words[1] != "-":
						card[words[0]] = words[1]
				elif "[Name]" not in card:
					card["[Name]"] = text
				elif "[Number]" not in card:
					card["[Number]"] = text
				elif '[Illustrator]' not in card:
					card['[Illustrator]'] = text
				elif "[Flavor Text]" not in card:
					if text != "-":
						card["[Flavor Text]"] = text
				else:
					if text != "-":
						card["[Text]"] = text

		src = tr.find("th").find("img")['src']
		if str(src).endswith(".jpg"):
			filename = str(card["[Number]"]).replace("/", "-")+".jpg"
			attempts = 3
			card["[Image]"] = filename
			while not os.path.isfile("src/cardfaces/"+filename):
				try:
					data = urllib.request.urlopen("http://cf-vanguard.com/en/cardlist/"+str(src), None, 10).read()
					with open("src/cardfaces/"+filename, "wb") as img:
						img.write(data)
				except socket.timeout:
					attempts -= 1
					print("timeout (10s): http://cf-vanguard.com/en/cardlist/"+str(src))
					if attempts > 0:
						print("retrying...")
					else:
						break
				except (urllib.error.HTTPError, urllib.error.URLError):
					print("error downloading: http://cf-vanguard.com/en/cardlist/"+str(src))
					break

		cards.append(card)
		print(str(len(cards))+" / "+str(len(trs)))


def save_cards():
	with open("cards.json", "w") as file:
		json.dump(cards, file, indent=1)

if __name__ == '__main__':
	main()
