PROG= mtc

CXX =

CLANG_CHECK = $(shell which clang++ >/dev/null; echo $$?)
ifeq "$(CLANG_CHECK)" "0"
CXX = clang++
CXXFLAGS = -Weverything -Wno-documentation-unknown-command -Wno-padded
else
GCC_CHECK = $(shell which g++ >/dev/null; echo $$?)
ifeq "$(GCC_CHECK)" "0"
CXX = g++
CXXFLAGS = -Wall --pedantic --std=gnu99
endif
endif

INC= -I. -I./loki/include

LIBS= -lloki
LIBS_DIR= -L./loki/lib

CXXFLAG_DEBUG= -pg -g $(INC)
CXXFLAG_RELEASE= -O2 -DNDEBUG $(INC)
CXXFLAG = $(CXXFLAG_DEBUG)

PH_FILE= ./headers/ph.hpp
PHFLAG = -c -o ./headers/ph.gch -x c++

# BISON
BISON = bison++
PARSER_DEFINITION_FILE = ./bison_parser.y
PARSER_SOURCE_CODE_FILE = ./bison_parser.cpp
PARSER_HEADER_FILE_NAME = ./headers/bison_parser.hpp
BISONFLAG = -v -d -h$(PARSER_HEADER_FILE_NAME) -o$(PARSER_SOURCE_CODE_FILE)

# FLEX
FLEX = flex++
LEXER_DEFINITION_FILE = ./scanner.l
LEXER_SOURCE_CODE_FILE = ./scanner.cpp
FLEXFLAG = -I

SRC = $(wildcard *.cpp)
OBJS = $(SRC:.cpp=.o)

DEP= makefile.dep

%.o: %.cpp | requirements
	$(CXX) $(CXXFLAG) -c $<

$(PROG): $(OBJS)
	$(CXX) $(OBJS) $(LIBS) $(LIBS_DIR) -o $@

all: ccomp $(PROG)

ccomp: $(PARSER_DEFINITION_FILE) $(LEXER_DEFINITION_FILE)
	$(BISON) $(BISONFLAG) $(PARSER_DEFINITION_FILE)
	$(FLEX) $(FLEXFLAG) $(LEXER_DEFINITION_FILE)

ph: $(PH_FILE)
	$(CXX) $(PHFLAG) $(PH_FILE)

depend:
	$(CXX) -I. -MM $(OBJS:.o=.cpp) > $(DEP)

clean:
	rm -f $(OBJS) $(PROG)

clean_all:
	rm -f $(OBJS) $(PROG)
	rm -f $(PARSER_SOURCE_CODE_FILE) $(LEXER_SOURCE_CODE_FILE) $(PARSER_SOURCE_CODE_FILE:.cpp=.output)

run_tests:
	./start_tests.sh

clean_tests:
	rm -f ./tests/*.s
	rm -f ./tests/*.o
	rm -f ./tests/*.exe

check_syntax_only: $(OBJS)
	$(CXX) $(CXXFLAG) -S $<

ifeq ($(wildcard $(DEP)), $(DEP))
include $(DEP)
endif

#.PHONY: requirements
requirements:
ifndef CXX
	$(error Missing compilator. Please install g++ or clang++)
endif

