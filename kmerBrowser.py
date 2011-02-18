#!/usr/bin/env python

from quixote.publish import Publisher
from quixote.directory import Directory
from quixote.util import StaticDirectory
import quixote
from urllib import quote_plus
import pkg_resources
import os.path
import jinja2
from quixote.form import Form, StringWidget, PasswordWidget
from sqlite3 import *
import khmer 
from screed import ScreedDB
from quixote.util import StaticFile

class myFirstUI(Directory):
	_q_exports = ['','firstkMer','kmerNeighborhood']
	theK=17
	
	def __init__(self):
		# the 12 is the size of K which can be set here:
		#self.ktable=khmer.new_ktable(12)
		self.ktable=khmer.new_hashbits(self.theK,1e9,4)
		#specify the files you want to load, they have to be screed files
		names=('chr01.fsa','chr02.fsa','chr03.fsa','chr04.fsa','chr05.fsa','chr06.fsa','chr07.fsa',
		'chr08.fsa','chr09.fsa','chr10.fsa','chr11.fsa','chr12.fsa','chr13.fsa','chr14.fsa','chr15.fsa','chr16.fsa')

		for name in names:
			self.fadb=ScreedDB(name)
			print name
			keys=self.fadb.keys()
			for key in keys:
				s=self.fadb[key]['sequence']
				self.ktable.consume(str(s))
		print "done consuming"
		
	def _q_index(self):
		return "kmer browser database"

	def firstkMer(self):
		i=0
		while self.ktable.get(i)==0:
			i+=1
		return self.ktable.reverse_hash(i)

	def addAllKmers(self,currentKmer,depth,maxDepth):
		if depth<maxDepth:
			L=['A','C','G','T']
			rawStringLead=currentKmer[0:(self.theK-1)]
			rawStringTrail=currentKmer[1:self.theK]
			for l in L:
				s=rawStringTrail+l
				if self.ktable.get(s)!=0: 
					self.lines[currentKmer+'	'+s]=1
					if not s in self.liste:
						self.liste[s]=depth+1
						self.addAllKmers(s,depth+1,maxDepth)
				s=l+rawStringLead
				if self.ktable.get(s)!=0:
					self.lines[currentKmer+'	'+s]=1
					if not s in self.liste:
						self.liste[s]=depth+1
						self.addAllKmers(s,depth+1,maxDepth)
			
	def kmerNeighborhood(self):
		request=quixote.get_request()
		form=request.form
		n=int(form['n'])
		print n
		self.liste=dict()
		self.lines=dict()
		self.liste.clear()
		self.lines.clear()
		self.liste[str(form['kmer'])]=0
		self.addAllKmers(str(form['kmer']),0,n)
		S=str(len(self.liste))+'\n'
		for l in self.liste.keys():
			S=S+l+'	'+str(self.liste[l])+'\n'
		for l in self.lines.keys():
			S=S+l+'\n'
		return S
	
	def interface(self):
		myVariable=templatesdir
		template = env.get_template('kMerBrowserInterface.html')
		return template.render(locals())
		
def create_publisher():
	publisher = Publisher(myFirstUI(),display_exceptions='plain',)
	return publisher

if __name__ == '__main__':
	thisdir = os.path.dirname(__file__)
	templatesdir = os.path.join(thisdir, 'data')
	templatesdir = os.path.abspath(templatesdir)
	loader = jinja2.FileSystemLoader(templatesdir)
	env = jinja2.Environment(loader=loader)
		
	from quixote.server.simple_server import run
	
	# please choose your publisher here:
	#keep in mind that this publisher has to match the kmerBrowserInterface URL!
	
	print 'creating demo listening on http://vertex.beacon.msu.edu:8080/'
	#run(create_publisher, host='localhost', port=8080)
	run(create_publisher, host='vertex.beacon.msu.edu', port=8080)