Do not use conf.d directory inside ~/.config/fontconfig/ with linking into conf.d from /etc/fonts/conf.avail/ because they are not guaranteed to override the ones in /etc/fonts/conf.d/
This is because if they use <edit ... mode="append"> the value will not be overwritten.
Better to just put everything in ~/.config/fontconfig/fonts.conf like this:
<match target="font">
	<edit name="rgba" mode="assign"><const>rgb</const></edit>
</match>

Also note that no reloading is needed to change configurations like above.
Just kill all instances of the app and restart it to see changes.
To make sure the config is read:
FC_DEBUG=1024 thunar
will print debug messages for reading configs and their order.
