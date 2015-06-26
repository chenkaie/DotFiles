" Learn Vimscript the Hard Way:
" http://learnvimscriptthehardway.stevelosh.com/

if has("cscope")
	""""""""
	" VVTK "
	""""""""
	let s:dm38x_modules =
	\ ['/home/kent.chen/Project/DM385/SD8161/apps/app_cluster/media',
	\  '/opt/Vivotek/lsp/DM8127/SDK/IPNCRDK_V3.8.0/syslink_2_21_02_10/packages/ti',
	\  '/opt/Vivotek/lsp/DM8127/SDK/IPNCRDK_V3.8.0/hdvpss_01_00_01_37/packages/ti',
	\  '/opt/Vivotek/lsp/DM8127/SDK/IPNCRDK_V3.8.0/bios_6_37_01_24/packages/ti',
	\  '/home/kent.chen/Project/DM385/SD8161/apps/app_cluster/common',
	\  '/home/kent.chen/Project/DM385/SD8161/apps/app_cluster/ptzctrl/app/ptzctrl.speeddomeIII']

	command! -nargs=* DM38X call DM38X()
	function! DM38X()
		echohl Wildmenu | echo "<<<<< Use DM38X related cscope/tags >>>>>" | echohl None
		let i = 0
		while i < len(s:dm38x_modules)
			exe "cs add " . s:dm38x_modules[i] . "/cscope.out " . s:dm38x_modules[i]
			exe "set tags +=" . s:dm38x_modules[i] . "/tags"
			let i += 1
		endwhile
	endfunction

	command! -nargs=* DM38XGEN call DM38XGEN()
	function! DM38XGEN()
		echohl Wildmenu | echo "<<<<< Generate DM38X related cscope/tags >>>>>" | echohl None
		let i = 0
		while i < len(s:dm38x_modules)
			silent exe "!tag_rebuild " . s:dm38x_modules[i]
			let i += 1
		endwhile
		exe "redraw!"
	endfunction

	""""""""
	" UBNT "
	""""""""
	let s:gen2_modules =
	\ ['$HOME/project/aircam-gm-gen2/sources',
	\  '$HOME/project/aircam-gm-gen2/packages-other',
	\  '$HOME/project/uClibc',
	\  '$HOME/project/linux-2.6.38.8']
	command! -nargs=* GEN2 call GEN2()
	function! GEN2()
		echohl Wildmenu | echo "<<<<< Use GEN2 related cscope/tags >>>>>" | echohl None
		let i = 0
		while i < len(s:gen2_modules)
			exe "cs add " . s:gen2_modules[i] . "/cscope.out " . resolve(expand(s:gen2_modules[i]))
			exe "set tags +=" . resolve(expand(s:gen2_modules[i])) . "/tags"
			let i += 1
		endwhile
	endfunction

	let s:gen3_modules =
	\ ['$HOME/project/aircam-gm-gen3/sources',
	\  '$HOME/project/aircam-gm-gen3/packages-other',
	\  '$HOME/project/uClibc',
	\  '$HOME/project/linux-3.10']
	command! -nargs=* GEN3 call GEN3()
	function! GEN3()
		echohl Wildmenu | echo "<<<<< Use GEN3 related cscope/tags >>>>>" | echohl None
		let i = 0
		while i < len(s:gen3_modules)
			exe "cs add " . s:gen3_modules[i] . "/cscope.out " . resolve(expand(s:gen3_modules[i]))
			exe "set tags +=" . resolve(expand(s:gen3_modules[i])) . "/tags"
			let i += 1
		endwhile
	endfunction

endif


