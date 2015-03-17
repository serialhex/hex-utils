(in-package :asdf-user)

(defsystem "hex-utils"
  :description  "serialhex utils"
  :version      "0.0.1"
  :author       "Justin Patera <serialhex@gmail.com>"
  :license      "MIT"

  :pathname "src"
  :serial       t
  :components
   ((:file "package")
    (:file "utils")
    (:file "macro-bang")
    (:file "list-builders")
    (:file "anaphora")
    (:file "closures")
    (:file "sub-scope")
    (:file "pandoric")
    (:file "lazy")
    (:file "misc")
    ))
