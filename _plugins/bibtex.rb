# Generates site.data["citations"] from _bibliography/papers.bib at build time,
# so the .bib file is the single source of truth for the publications page.
# Replaces the template's Manubot/ORCID pipeline (_cite/), which required DOIs
# and mangled CS venue metadata.
#
# Supported custom fields (al-folio conventions):
#   abbr          venue abbreviation, shown as a tag (e.g. NeurIPS, TACL)
#   arxiv         arXiv id, adds an "arXiv" button and default link
#   pdf           PDF url (bare filenames are ignored), adds a "PDF" button
#   html          publisher page url, used as the title link when present
#   code          repository url, adds a "Code" button
#   supp          supplement url (bare filenames are ignored)
#   selected      true to surface in the "Highlighted" section
#
# Lab member names (from the members collection) are bolded in author lists.

require "bibtex"

module Jekyll
  class BibtexCitations < Generator
    priority :highest

    BIB_PATH = File.join("_bibliography", "papers.bib")
    MONTHS = %w[jan feb mar apr may jun jul aug sep oct nov dec]

    def generate(site)
      path = File.join(site.source, BIB_PATH)
      return unless File.exist?(path)

      members = member_names(site)
      bib = BibTeX.open(path, filter: :latex)
      site.data["citations"] = bib.entries.values
        .map { |entry| citation(entry, members) }
        .sort_by { |citation| citation["date"] }
        .reverse
    end

    private

    def member_names(site)
      docs = site.collections["members"]&.docs || []
      docs.filter_map { |doc| normalize(doc.data["name"]) unless doc.data["name"].to_s.empty? }
    end

    # normalized form for matching bib names to member names, tolerant of
    # hyphenation and name-order differences ("Zhi-Xuan, Tan" vs "Tan Zhi Xuan")
    def normalize(name)
      name.to_s.downcase.gsub(/[^a-z]+/, " ").split.sort.join(" ")
    end

    def field(entry, key)
      return nil unless entry.field?(key)
      text = entry[key].to_s.gsub(/[{}]/, "").strip
      text.empty? ? nil : text
    end

    def citation(entry, members)
      {
        "id" => id(entry),
        "type" => type(entry),
        "title" => field(entry, :title),
        "authors" => authors(entry, members),
        "publisher" => venue(entry),
        "date" => date(entry),
        "date_text" => date_text(entry),
        "link" => link(entry),
        "buttons" => buttons(entry),
        "abstract" => field(entry, :abstract),
        "bibtex" => bibtex(entry),
        "selected" => entry.field?(:selected) && entry[:selected].to_s.strip == "true",
      }.compact
    end

    def authors(entry, members)
      return nil unless entry.field?(:author)
      authors = entry.author.map do |name|
        display = [name.first, name.prefix, name.last, name.suffix].compact.join(" ")
        members.include?(normalize(display)) ? "**#{display}**" : display
      end
      authors[-1] = "and #{authors[-1]}" if authors.length > 1
      authors
    end

    def preprint?(entry)
      field(entry, :journal).to_s =~ /arxiv preprint/i ? true : false
    end

    def type(entry)
      preprint?(entry) ? "preprint" : "paper"
    end

    def venue(entry)
      return "arXiv preprint" if preprint?(entry)
      field(entry, :journal) ||
        field(entry, :booktitle) ||
        (field(entry, :school) && "PhD thesis, #{field(entry, :school)}") ||
        field(entry, :organization) ||
        field(entry, :publisher)
    end

    def year(entry)
      field(entry, :year).to_s[/\d{4}/]&.to_i
    end

    def month(entry)
      raw = field(entry, :month).to_s.downcase
      return raw.to_i if raw =~ /^\d+$/ && (1..12).cover?(raw.to_i)
      index = MONTHS.index(raw[0, 3])
      index && index + 1
    end

    def date(entry)
      return nil unless year(entry)
      format("%04d-%02d-01", year(entry), month(entry) || 1)
    end

    def date_text(entry)
      return nil unless year(entry)
      if month(entry)
        "#{MONTHS[month(entry) - 1].capitalize} #{year(entry)}"
      else
        year(entry).to_s
      end
    end

    # standard fields to keep in the copyable BibTeX snippet (site-specific
    # fields like abstract, pdf, selected are stripped)
    BIBTEX_FIELDS = %i[
      title author editor journal booktitle school organization series
      volume number pages publisher year month doi
    ].freeze

    def bibtex(entry)
      copy = BibTeX::Entry.new
      copy.type = entry.type
      copy.key = entry.key
      BIBTEX_FIELDS.each do |key|
        copy[key] = entry[key].to_s if entry.field?(key)
      end
      copy.to_s
    end

    def id(entry)
      if field(entry, :doi)
        "doi:#{field(entry, :doi)}"
      elsif field(entry, :arxiv)
        "arXiv:#{field(entry, :arxiv)}"
      else
        entry.key.to_s
      end
    end

    def url?(value)
      value.to_s =~ %r{^https?://} ? true : false
    end

    def pdf_url(entry)
      pdf = field(entry, :pdf)
      url?(pdf) ? pdf : nil
    end

    def arxiv_url(entry)
      field(entry, :arxiv) && "https://arxiv.org/abs/#{field(entry, :arxiv)}"
    end

    def doi_url(entry)
      field(entry, :doi) && "https://doi.org/#{field(entry, :doi)}"
    end

    def link(entry)
      html = field(entry, :html)
      (url?(html) ? html : nil) ||
        arxiv_url(entry) ||
        doi_url(entry) ||
        pdf_url(entry) ||
        field(entry, :url)
    end

    def buttons(entry)
      buttons = []
      if arxiv_url(entry)
        buttons << { "type" => "arxiv", "text" => "arXiv", "link" => arxiv_url(entry) }
      end
      if pdf_url(entry)
        buttons << { "type" => "paper", "text" => "PDF", "link" => pdf_url(entry) }
      end
      if url?(field(entry, :html))
        buttons << { "type" => "website", "text" => "Publisher", "link" => field(entry, :html) }
      end
      if field(entry, :code)
        buttons << { "type" => "source", "text" => "Code", "link" => field(entry, :code) }
      end
      if url?(field(entry, :supp))
        buttons << { "type" => "docs", "text" => "Supplement", "link" => field(entry, :supp) }
      end
      buttons.empty? ? nil : buttons
    end
  end
end
