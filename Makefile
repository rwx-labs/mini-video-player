all: build/tiktok.html build/reddit.html

build/tiktok.html: player.html
	mkdir -p build
	sed 's/%%VIDEO_BASE_DIR%%/tiktok/g' player.html | \
		html-minifier-terser \
			--collapse-whitespace \
			--minify-js true \
			--minify-css true \
			--minify-urls true \
			--remove-optional-tags > build/tiktok.html

build/reddit.html: player.html
	mkdir -p build
	sed 's/%%VIDEO_BASE_DIR%%/reddit/g' player.html | \
		html-minifier-terser \
			--collapse-whitespace \
			--minify-js true \
			--minify-css true \
			--minify-urls true \
			--remove-optional-tags > build/reddit.html

.PHONY: upload
upload:
	aws --profile cloudflare-r2 --endpoint-url "https://262cf8aeb384b1f034577956e3baa60a.r2.cloudflarestorage.com" s3 cp build/tiktok.html s3://rwx-pub/tiktok --content-type "text/html"
	aws --profile cloudflare-r2 --endpoint-url "https://262cf8aeb384b1f034577956e3baa60a.r2.cloudflarestorage.com" s3 cp build/reddit.html s3://rwx-pub/reddit --content-type "text/html"

.PHONY: clean
clean:
	rm -rf "build/"
