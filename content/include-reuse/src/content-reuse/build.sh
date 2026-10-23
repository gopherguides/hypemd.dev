set -eu

mkdir -p output
hype export -format markdown -f docs.md -o output/docs.md
hype export -format html -f blog.md -o output/blog.html
hype export -format html -f course.md -o output/course.html

printf '%s\n' output/docs.md output/blog.html output/course.html
