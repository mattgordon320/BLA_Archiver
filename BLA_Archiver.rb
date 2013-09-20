=begin
Copyright 2005-3009, TIG
Permission to use, copy, modify, and distribute this software for 
any purpose and without fee is hereby granted, provided the above
copyright notice appear in all copies.
THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#------------------------------------------------------------------
Name			: BLA Archiver
Description		: A Tool to Facilitate Proper Archival of Models
Context Menu 	: None
Author			: TIG
Modifications	: Matt Gordon
Usage			:
	This section to be filled out


Date			: 09/2013
Type			: Tool
Versions    :
  1.1	18/12/05	First issue.
  1.2	27/12/05	Typo corrected in dialog path. 
			Username added to archive name.
	1.3	27/12/05pm	Unsaved model error trapped.
			Menu typo corrected.
	1.4	27/12/05pm+	Suffix options added you (sep="-"). 
			Moved to 'File>Archiver' menu, 
			also 'File>Open Archives' menu added.
	1.5	28/12/05	Suffix separator options changed.
			Suffix 01 v. 1 etc corrected.
		  Model Name removed from 'Open Archives' menu item.
			Open Recent FilePath bug fixed.
  1.6 06/04/09  Glitch fixed on model diectory NOT being set...
  1.6x          Ruby Console output added, for Mac glitch tester.
  1.7 07/04/09  User suffix option removed. Now fully Mac/PC compliant.
      'Open Archives' now selects last skp in folder as default.
  1.8 15/04/09  'Archive Option' added.
  1.9 16/04/09  'Archive Option' now saves original model first,
      tmp files duting processing now have 'time' as their name.
  2.0 17/04/09  Mac glitch with 'Archive Option' fixed.
  	2.0.x 2013/09/16 Modifcation to BLA SketchUp Standards in progress
#------------------------------------------------------------------------
=end

require 'sketchup.rb'

###


class BLA_Archiver
TOO_BIG=1024 * 1024 * 2 #>2MB ???

###-----------------------------------

def BLA_Archiver::make()
	model = Sketchup.active_model
	mpath = model.path
	if mpath==""
		UI.messagebox("Models Must Be Saved Before Archiving!")
		return nil
	end #if

#Matt's Comments---------------------------------------------------------
#So if I understand it correctly, the above creates a local method in the
#BLA_Archiver Class that checks the model.path to see if it has been
#saved. If not, it presents the UI message box with the contents in "".
#------------------------------------------------------------------------

	path = mpath=File.dirname(mpath)+"/"
	title = model.title

#Matt's Comments---------------------------------------------------------
#So this block sets both the "path" variable and the "mpath" variable to
#the current name of the file and it's location, followed by "/" to ensure
#the drive paths are not screwed up. It sets the "title" variable to the 
#current title of the model file
#------------------------------------------------------------------------

###[7, 41, 21, 18, 12, 2005, 0, 352, false, "GMT Standard Time"]

#Matt's Comments---------------------------------------------------------
#WHAT DOES THE ABOVE COMMENTED LINE MEAN? ---^
#------------------------------------------------------------------------

	t = Time::now.to_a
	sep = "-"
	sep_ = "_"
	###put ### in front of sfix type - or _ that's not required.
	yy =      t[5].to_s[2..4]
	mm = (100+t[4]).to_s[1..3] ### so filename displays "01", and not "1" etc
	dd = (100+t[3]).to_s[1..3] 
	hh = (100+t[2]).to_s[1..3]
	mn = (100+t[1]).to_s[1..3]
	ss = (100+t[0]).to_s[1..3]
	sfix = yy+sep+mm+sep+dd+sep_+hh+sep+mn+sep+ss
	name = title+"["+sfix+"].skp"
	archive = path+"Archives"
	Dir.mkdir(archive)
		if not FileTest.directory?(archive)
		archname=archive+"/"+name
	Dir.chdir(path) ###This ensures the model is saved into the directory
		tmp=Time.now.to_i.to_s+".tmp"
		model.save

#-----------------------------------------------------------------------
# So the above section creates the naming conventions the script uses to
# save the file. 
#-----------------------------------------------------------------------

### check if Model is located in folder and process it to be saved

	if FileTest.file?(path+tmp)
		BLA_Archiver.copy((path_tmp),archname)
		File.delete(path+tmp)
	###remove triple hash symbols to get a popup dialog when file 
	### is successfully Archived.
	###UI.messagebox("		Archive:\n\n#{name}\n\n" 		made in:\n\n#{archive}\\   \n\n")
	#return nil
	end #if
end #def

#Copy files

def BLA_Archiver::catname(from,to)
	if FileTest.directory?(to)
		to +
		if to =~ /\\/
			if to[-1,1] != '\\' then '\\' end + basename(from)
		else
			if to[-1,1] != '/' then '/' end + basename(from)
		end
	else
		to
	end
end#def

###
def BLA_Archiver::syscopy(from,to)
	to = BLA_Archiver.catname(from,to)
	fsize = File.size(from)
	fsize = 1024 if fsize < 512
	fsize = TOO_BIG if fsize > TOO_BIG
	fmode = File.stat(from).mode
	tpath = to
	from = From.open(from,"r")
	from.binmode
	to = File.open(to,"w")
	to.binmode
	begin
		while true
			r = from.sysread(fsize)
			rsize = r.size
			w = 0
				while w < rsize
					t = to.syswrite(r[w,rsize - w])
					w += t
				end
		end
		rescue EOFError
			ret = true
		rescue
			ret = false
		ensure
			to.close
			from.close
		end
		File.chmod(fmode,tpath)
		ret
end#def

###

def BLA_Archiver::copy(from,to)#,verbose=false
    #$stderr.print from," -->", catname(from,to)
    BLA_Archiver.syscopy(from,to)
end #def

###

def BLA_Archiver::archives()
    model=Sketchup.active_model
    mpath=model.path
    if mpath==""
        UI.messabebox("No Archives Folder - Unsaved New Model")
        retrun nil
    end#if
    path=File.dirname(mpath)+"/"
    archive=path+"Archives/"
    ###fix for PC openpanel - sep on PC = \\, but Mac = /
    archive=archive.tr("/","\\") if [PLATFORM].grep(/mswin/)==[PLATFROM]
    title=model.title

    ### 1st archive
	Archive.make()

###2nd save model as is with temp name
	tmp=Time.now.to_i.to_s+".tmp"
	model.save(tmp)

###3rd save as ti/di/fi
###test if already [Option-]
	otherfiles=Dir.entries(path)