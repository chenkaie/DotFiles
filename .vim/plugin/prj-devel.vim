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
	let s:gen2_modules = [
	\  '$HOME/project/unifi-video-firmware-gen2/packages-other',
	\  '$HOME/project/build_dir_target',
	\  '$HOME/project/uClibc',
	\  '$HOME/project/linux-2.6.38.8'
	\ ]
	command! -nargs=* GEN2 call GEN2()
	function! GEN2()
		echohl Wildmenu | echo "<<<<< Use GEN2 related cscope/tags >>>>>" | echohl None
		set cscopeprg=cscope
		let i = 0
		while i < len(s:gen2_modules)
			exe "cs add " . s:gen2_modules[i] . "/cscope.out " . resolve(expand(s:gen2_modules[i]))
			exe "set tags +=" . resolve(expand(s:gen2_modules[i])) . "/tags"
			let i += 1
		endwhile
	endfunction

	let s:gen3_modules = [
	\  '$HOME/project/unifi-video-firmware-codetrace/packages/',
	\  '$HOME/project/uClibc',
	\  '$HOME/project/linux-3.10'
	\ ]
	command! -nargs=* GEN3 call GEN3()
	function! GEN3()
		echohl Wildmenu | echo "<<<<< Use GEN3 related cscope/tags >>>>>" | echohl None
		set cscopeprg=cscope
		let i = 0
		while i < len(s:gen3_modules)
			exe "cs add " . s:gen3_modules[i] . "/cscope.out " . resolve(expand(s:gen3_modules[i]))
			exe "set tags +=" . resolve(expand(s:gen3_modules[i])) . "/tags"
			let i += 1
		endwhile
	endfunction

	let s:gen4_modules = [
	\  '$HOME/project/unifi-video-firmware-codetrace/packages/',
	\  '$HOME/project/glibc',
	\  '$HOME/project/linux-4.9'
	\ ]
	command! -nargs=* GEN4 call GEN4()
	function! GEN4()
		echohl Wildmenu | echo "<<<<< Use GEN4 related cscope/tags >>>>>" | echohl None
		set cscopeprg=cscope
		let i = 0
		while i < len(s:gen4_modules)
			exe "cs add " . s:gen4_modules[i] . "/cscope.out " . resolve(expand(s:gen4_modules[i]))
			exe "set tags +=" . resolve(expand(s:gen4_modules[i])) . "/tags"
			let i += 1
		endwhile
	endfunction

	let s:gen4c_modules = [
	\  '$HOME/project/unifi-video-firmware-codetrace/packages/',
	\  '$HOME/project/glibc',
	\  '$HOME/project/linux-5.4.61'
	\ ]
	command! -nargs=* GEN4C call GEN4C()
	function! GEN4C()
		echohl Wildmenu | echo "<<<<< Use GEN4C related cscope/tags >>>>>" | echohl None
		set cscopeprg=cscope
		let i = 0
		while i < len(s:gen4c_modules)
			exe "cs add " . s:gen4c_modules[i] . "/cscope.out " . resolve(expand(s:gen4c_modules[i]))
			exe "set tags +=" . resolve(expand(s:gen4c_modules[i])) . "/tags"
			let i += 1
		endwhile
	endfunction

	let s:gen3s_modules = [
	\  '$HOME/project/unifi-video-firmware-codetrace/packages/',
	\  '$HOME/project/glibc',
	\  '$HOME/dl/sstar-sdk-pretzel-gcc-8.2.1/kernel',
	\  '$HOME/dl/sstar-sdk-pretzel-gcc-8.2.1/project/release/ipc',
	\  '$HOME/.ubnt/cache/gen3s/barebones/staging_dir/target-arm-openwrt-linux-gnu_glibc/usr'
	\ ]
	command! -nargs=* GEN3S call GEN3S()
	function! GEN3S()
		echohl Wildmenu | echo "<<<<< Use GEN3S related cscope/tags >>>>>" | echohl None
		set cscopeprg=cscope
		let i = 0
		while i < len(s:gen3s_modules)
			exe "cs add " . s:gen3s_modules[i] . "/cscope.out " . resolve(expand(s:gen3s_modules[i]))
			exe "set tags +=" . resolve(expand(s:gen3s_modules[i])) . "/tags"
			let i += 1
		endwhile
	endfunction

	let s:ufp_sfl_modules = [
	\  '$HOME/project/protect-eot-firmware-codetrace',
	\  '$HOME/project/linux-eot-sfl',
	\  '$HOME/project/uClibc'
	\ ]
	command! -nargs=* UFPSFL call UFPSFL()
	function! UFPSFL()
		echohl Wildmenu | echo "<<<<< Use UFPSFL related cscope/tags >>>>>" | echohl None
		set cscopeprg=cscope
		let i = 0
		while i < len(s:ufp_sfl_modules)
			exe "cs add " . s:ufp_sfl_modules[i] . "/cscope.out " . resolve(expand(s:ufp_sfl_modules[i]))
			exe "set tags +=" . resolve(expand(s:ufp_sfl_modules[i])) . "/tags"
			let i += 1
		endwhile
	endfunction

endif


