" Learn Vimscript the Hard Way:
" http://learnvimscriptthehardway.stevelosh.com/

if has("cscope")
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
endif


