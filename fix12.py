import sys

with open('frontend_web/dashboard.html', 'r', encoding='utf-8') as f:
    text = f.read()

bad_string = '''  <div id="google_translate_element" style="display:none;"></div>
  <script type="text/javascript">
    function googleTranslateElementInit() {
      new google.translate.TranslateElement({pageLanguage: 'en', includedLanguages: 'en,hi', autoDisplay: false}, 'google_translate_element');
    }
  </script>
  <script type="text/javascript" src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>'''

text = text.replace(bad_string, '')

with open('frontend_web/dashboard.html', 'w', encoding='utf-8') as f:
    f.write(text)
