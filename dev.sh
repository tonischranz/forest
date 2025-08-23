echo "
----()-
-------
."

echo hallo

docker run -it -p 8080:5173 -v .:/app -w /app node:24-alpine yarn dev
