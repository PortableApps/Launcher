def setup(app):
    app.add_crossref_type('ini-section', 'ini-section', indextemplate='pair: INI section; %s')
    app.add_crossref_type('ini-key', 'ini-key', indextemplate='pair: INI key; %s')
    app.add_crossref_type('env', 'env', indextemplate='pair: environment variable; %s')
    # I know that there's 'envvar' but it chokes a bit (warning) on colons due to its index template
