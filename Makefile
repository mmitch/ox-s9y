# Makefile for ox-s9y
#
# Copyright (C) 2017-2021  Christian Garbs <mitch@cgarbs.de>
# Licensed under GNU GPL v3 or later.
#
# This file is part of ox-s9y.
#
# ox-s9y is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ox-s9y is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ox-s9y.  If not, see <http://www.gnu.org/licenses/>.

SOURCES=$(wildcard *.el)
TARGETS=$(addsuffix c,$(SOURCES))
TESTS=$(basename $(wildcard testing/test-*.el))

EMACS=emacs -Q --batch

%.elc: %.el
	$(EMACS) -f batch-byte-compile $<

testing/test-%: %.elc testing/test-%.el
	$(EMACS) -l ert -l $< -l $@.el -f ert-run-tests-batch-and-exit

all:	compile test

compile: $(TARGETS)

test: show-emacs-version show-org-version $(TESTS)

show-emacs-version:
	$(EMACS) --version

show-org-version:
	$(EMACS) -f org-version

clean:
	rm -f *.elc
	rm -f *~ testing/*~
