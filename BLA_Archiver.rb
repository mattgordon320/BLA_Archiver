=begin
Copyright 2005-3009, TIG
Permission to use, copy, modify, and distribute this software for 
any purpose and without fee is hereby granted, provided the above
copyright notice appear in all copies.
THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#------------------------------------------------------------------
Name			: BLA_Archiver
Description		: A Tool to Facilitate Archival of Model matching personal/company standards
Context Menu 	: None
Author			: TIG
Modifications	: Matt Gordon
Usage			: This section to be filled out once script is completed
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

###BEGIN WRITTEN CLASSES AND METHODS

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
	#saved. If not, it presents the UI message box with the contents between
	#the "".
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
	#I'm completely flummoxed by the above commented line. Could you let me
	#know what the array signifies? Is it something like time zone formatting?
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

	#Matt's Comments--------------------------------------------------------
	# So the above section creates the numerous variables that regulate the
	# naming conventions the script uses to save the file, such as the separators
	# used, and the different time formats. I must ask though, I'm a little thrown
	# by the use of the (100+t[4]) expression. I'm getting the vague flickers of
	# meaning, but I can't fully work it out. Time gets converted to an array on
	# line #84, and then used in that expression, whose output is then converted 
	# to a string for use in the variable "sfix" on line 94. Could you enlighten
	# as to the full significance of how that works?
	#-----------------------------------------------------------------------

		Dir.mkdir(archive)
			if not FileTest.directory?(archive)
			archname=archive+"/"+name
		Dir.chdir(path) ###This ensures the model is saved into the directory
			tmp=Time.now.to_i.to_s+".tmp"
			model.save

	#-----------------------------------------------------------------------
	# The block above checks to see whether the Archives directory exists,
	# and if not, it will make it, and then set the directory path correctly
	# to receive the temp file it writes.
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

	###Copy files

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
		        UI.messabebox("No Archives Folder - Unsaved New Model!")
		        retrun nil
		    end#if
	    path=File.dirname(mpath)+"/"
	    archive=path+"Archives/"
	    ###fix for PC openpanel - sep on PC = \\, but Mac = /
	    archive=archive.tr("/","\\") if [PLATFORM].grep(/mswin/)==[PLATFROM]
	    title=model.title
		    if not FileTest.directory?(archive)
		    	UI.messagebox("NO 'Archives' Folder for '#{title}' ! ")
		    	return nil
		    end#if
	    skp=(Dir.entries(archive).sort!).last
	    arch=UI.openpanel("Open Archive File (#{title}...",archive,skp)
	    Sketchup.open_file(arch) if arch
	end#def

	    ###

	def BLA_Archiver::option()
		model=Sketchup.active_model
		mpath=model.path
		    if mpath==""
			    UI.messagebox("You can't Archive/Option a New Model until you have saved it !  ")
			    return nil
	    	end#if
	    path=File.dirname(mpath)+"/"
	    ###fix for PC openpanel - sep on PC = \\, but Mac = /
	    spath=path
	    spath=path.tr("/","\\") if [PLATFORM].grep(/mswin/)==[PLATFORM]
	    title - model.title

	### 1st archive
		Archive.make()

	### 2nd save model as is with temp name
		tmp=Time.now.to_i.to_s+".tmp"
		model.save(tmp)

	###3rd save as ti/di/fi
	###test if already [Option-]
		otherfiles=Dir.entries(path)
		num=0; numi=nil
		otherfiles.each{|file|
			if file.include?("[")and numi=file.split("[")[1].split("[")[0].split("-")[1]
				num=numi.to_i if numi.to_i > num
			end#if
		}###num is the highest value option
		opt="[Option-"
		numi=0
			while numi <= num
				numi=numi+1
			end#if(while)
		title=title.split
		num=numi.to_s
		num = "0"+num if numi <10 #leading zero
		suf=opt+num+"]"
		title2=title+suf+".skp"
		save=UI.savepanel("Save the Model '"+title+"' as...",spath,title2)
			if save
				savef=File.basename(save)
				model.save(savef)
				Sketchup.open_file(save)
				###move original back now that it's closed
				File.rename(tmp,title+".skp")
			else ### erase tmp file if failed
				File.delete(tmp)
			end#if
	end#def

	###

	def BLA_Archiver::file_menu()
		@file_menu=UI.menu("File").add_item("Open Archives"){BLA_Archiver.archives}
	end#def
end#class

###
#----Menu-----------------------------------------------------
if(not file_loaded?(BLA_Archiver))
	add_separator_to_menu("File")
	UI.menu("File").add_item("BLA_Archiver"){BLA_Archiver.make}
	BLA_Archiver.file_menu
	UI.menu("File").add_item("Archive Version/Option"){BLA_Archiver.option}
end#if
file_loaded("BLA_Archiver.rb")
#-------------------------------------------------------------