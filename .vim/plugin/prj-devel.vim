" Learn Vimscript the Hard Way:
" http://learnvimscriptthehardway.stevelosh.com/

if has("cscope")
	command! -nargs=* DM38X call DM38X()
	function! DM38X()
		let modules = [ '/home/kent.chen/Project/DM385/SD8161/apps/app_cluster/media',
					  \ '/opt/Vivotek/lsp/DM8127/SDK/IPNCRDK_V3.8.0/syslink_2_21_02_10/packages/ti',
					  \ '/home/kent.chen/Project/DM385/SD8161/apps/app_cluster/common',
					  \ '/home/kent.chen/Project/DM385/SD8161/apps/app_cluster/ptzctrl/app/ptzctrl.speeddomeIII' ]

		echohl Wildmenu | echo "<<<<< Use DM38X related cscope/tags >>>>>" | echohl None
		let i = 0
		while i < len(modules)
			exe "cs add " . l:modules[i] . "/cscope.out " . modules[i]
			exe "set tags +=" . l:modules[i] . "/tags"
			let i += 1
		endwhile
	endfunction

	command! -nargs=* DM38XGEN call DM38XGEN()
	function! DM38XGEN()
		let modules = [ '/home/kent.chen/Project/DM385/SD8161/apps/app_cluster/media',
					  \ '/opt/Vivotek/lsp/DM8127/SDK/IPNCRDK_V3.8.0/syslink_2_21_02_10/packages/ti',
					  \ '/home/kent.chen/Project/DM385/SD8161/apps/app_cluster/common',
					  \ '/home/kent.chen/Project/DM385/SD8161/apps/app_cluster/ptzctrl/app/ptzctrl.speeddomeIII' ]

		echohl Wildmenu | echo "<<<<< Generate DM38X related cscope/tags >>>>>" | echohl None
		let i = 0
		while i < len(modules)
			silent exe "!tag_rebuild " . l:modules[i]
			let i += 1
		endwhile
		exe "redraw!"
	endfunction
endif


