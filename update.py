#!/usr/bin/env python3

from requests import post
from bs4 import BeautifulSoup

import os, socket, atexit, re
from os.path import basename, splitext
from json import dump
from urllib.request import urlopen
from urllib.error import HTTPError, URLError

NUM_CARDS = '100000'

cards = []

def main():
	atexit.register(save_cards)

	r = post('http://cf-vanguard.com/en/cardlist/cardsearch', data={
			'data[CardSearch][show_page_count]': NUM_CARDS,
			'data[CardSearch][keyword]': '',
			'cmd': 'search'
		})
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
				unit = re.split('[：:]', attribute, maxsplit=1)
				prop = unit[0].strip()
				if prop == '[Skill Icon]':
					prop = '[Skill]'
				try:
					if prop == '[Nation]':
						card[prop] = get_img_value(span, unit).replace('co_', '')
					elif prop == ['[Skill]']:
						card[prop] = get_img_value(span, unit).replace('sk_', '')
					elif prop == '[Trigger]':
						card[prop] = get_img_value(span, unit).replace('tr_', '')
					else:
						value = unit[1].strip()
						card[prop] = clean_value(value)
				except:
					card[prop] = ''
		text_span = spans[-1]
		text = ' '.join(text_span.stripped_strings)
		card['[Text]'] = clean_value(text)

		src = str(tr.find('th').find('img')['src'])
		ext = os.path.splitext(src)[1]
		if src:
			filename = str(card['[Number]']).replace('/', '-') + ext
			attempts = 3
			card['[Image]'] = filename
			while not os.path.isfile('src/cardfaces/' + filename):
				try:
					data = urlopen('http://cf-vanguard.com/en/cardlist/' + src, None, 10).read()
					with open('src/cardfaces/'+filename, 'wb') as img:
						img.write(data)
				except socket.timeout:
					attempts -= 1
					print('timeout (10s): http://cf-vanguard.com/en/cardlist/' + src)
					if attempts > 0:
						print('retrying...')
					else:
						break
				except (HTTPError, URLError):
					print('error downloading: http://cf-vanguard.com/en/cardlist/' + src)
					break

		cards.append(card)
		print(str(len(cards)) + ' / ' + str(len(trs)))

def get_img_value(span, unit):
	try:
		src = span.find('img')['src']
		return splitext(basename(src))[0]
	except:
		value = clean_value(unit[1].strip())
		if value != '':
			words = value.split(' ')
			fixed_words = []
			for word in words:
				if word[0] == '[' and word[-1] == ']':
					word = splitext(word[1:-1])[0]
				fixed_words.append(word)
			return ' '.join(fixed_words)

		return ''

def clean_value(value):
	if value != '-' and value != '-0':
		return value
	else:
		return ''

def save_cards():
	with open('cards.json', 'w') as file:
		dump(cards, file, indent=1)

if __name__ == '__main__':
	main()
