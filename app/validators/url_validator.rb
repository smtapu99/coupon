class UrlValidator < ActiveModel::EachValidator

  PERFECT_URL_PATTERN = %r{
    \A

    # protocol identifier
    (?:(?:https?|ftp)://)

    # user:pass authentication
    (?:\S+(?::\S*)?@)?

    (?:
      # IP address exclusion
      # private & local networks
      (?!10(?:\.\d{1,3}){3})
      (?!127(?:\.\d{1,3}){3})
      (?!169\.254(?:\.\d{1,3}){2})
      (?!192\.168(?:\.\d{1,3}){2})
      (?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})

      # IP address dotted notation octets
      # excludes loopback network 0.0.0.0
      # excludes reserved space >= 224.0.0.0
      # excludes network & broacast addresses
      # (first & last IP address of each class)
      (?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])
      (?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}
      (?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))
    |
      # host name
      (?:(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)

      # domain name
      (?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*

      # TLD identifier
      (?:\.(?:[a-z\u00a1-\uffff]{2,}))
    )

    # port number
    (?::\d{2,5})?

    # resource path
    (?:/[^\s]*)?

    \z
  }xi

  # https://gist.github.com/dperini/729294
  STRICT_URL_PATTERN = /\A(?:(?:https?|ftp):\/\/)(?:\S+(?::\S)?@)?(?:(?!10(?:.\d{1,3}){3})(?!127(?:.\d{1,3}){3})(?!169.254(?:.\d{1,3}){2})(?!192.168(?:.\d{1,3}){2})(?!172.(?:1[6-9]|2\d|3[0-1])(?:.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]+-?)[a-z\u00a1-\uffff0-9]+)(?:.(?:[a-z\u00a1-\uffff0-9]+-?)[a-z\u00a1-\uffff0-9]+)(?:.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/[^\s]*)?\z/i

  # http://stackoverflow.com/questions/16481641/php-regex-match-all-urls
  LOOSE_URL_PATTERN  = /^(http|https|ftp):\/\/([A-Z0-9][A-Z0-9_-]*(?:\.[A-Z0-9][A-Z0-9_-]*)+):?(\d+)?\/?/i

  # ANOTHER_PATTERN = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix

  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || "must be a valid URL") if value.present? && !url_valid?(value)
  end

  # a URL may be technically well-formed but may
  # not actually be valid, so this checks for both.
  def url_valid?(url)
    r = LOOSE_URL_PATTERN =~ url
    !r.nil?
  end
end
