import requests, json, urllib.request, os, socket, atexit
from bs4 import BeautifulSoup

cards = []

def main():
	atexit.register(save_cards)

	num_cards = '10000'
	r = requests.post('http://cf-vanguard.com/en/cardlist/cardsearch', data={'data[CardSearch][show_page_count]':num_cards, 'data[CardSearch][keyword]':'', 'cmd':'search'})
	r.encoding = 'utf-8'
	soup = BeautifulSoup(r.text, 'html.parser')
	trs = soup.find(id='searchResult-table').find_all('tr')
	os.makedirs('src/cardfaces', exist_ok=True)
	for tr in trs:
		card = {}
		td = tr.find('td')
		a = td.find('a')
		[name_span, number_span] = a.find_all('span')
		card['[Name]'] = name_span.string
		card['[Number]'] = number_span.string
		spans = td.find_all('span')
		for span in spans:
			if span.get('class') == ['unit']:
				attribute = ' '.join(span.stripped_strings)
				unit = attribute.split('：') if '：' in attribute else attribute.split(':')
				prop = unit[0].strip()
				try:
					if prop == '[Nation]':
						src = span.find('img')['src']
						card[prop] = src[src.find('co_') + 3 : src.rfind('.')]
					elif prop == '[Skill Icon]':
						try:
							src = span.find('img')['src']
							card['[Skill]'] = src[src.find('sk_') + 3 : src.rfind('.')]
						except:
							card['[Skill]'] = unit[1].strip()
					elif prop == '[Trigger]':
						src = span.find('img')['src']
						card[prop] = src[src.find('tr_') + 3 : src.rfind('.')]
					else:
						value = unit[1].strip()
						if value != '-' and value != '-0':
							card[prop] = value
				except:
					card[prop] = ''
		text_span = spans[-1]
		text = ' '.join(text_span.stripped_strings)
		if text != '-' and text != '-0':
			card['[Text]'] = text
		else:
			card['[Text]'] = ''

		src = str(tr.find('th').find('img')['src'])
		ext = os.path.splitext(src)[1]
		if src:
			filename = str(card['[Number]']).replace('/', '-') + ext
			attempts = 3
			card['[Image]'] = filename
			while not os.path.isfile('src/cardfaces/' + filename):
				try:
					data = urllib.request.urlopen('http://cf-vanguard.com/en/cardlist/' + src, None, 10).read()
					with open('src/cardfaces/'+filename, 'wb') as img:
						img.write(data)
				except socket.timeout:
					attempts -= 1
					print('timeout (10s): http://cf-vanguard.com/en/cardlist/' + src)
					if attempts > 0:
						print('retrying...')
					else:
						break
				except (urllib.error.HTTPError, urllib.error.URLError):
					print('error downloading: http://cf-vanguard.com/en/cardlist/' + src)
					break

		cards.append(card)
		print(str(len(cards)) + ' / ' + str(len(trs)))


def save_cards():
	with open('cards.json', 'w') as file:
		json.dump(cards, file, indent=1)

if __name__ == '__main__':
	main()
