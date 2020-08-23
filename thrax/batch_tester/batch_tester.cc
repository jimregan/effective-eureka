// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Copyright 2012 Center for Spoken Language Understanding
// Author: rws@xoba.com (Richard Sproat)
//
// Stand-alone binary to load up a FAR and rewrite some strings in batch mode.

#include <fst/compat.h>
#include <thrax/compat/compat.h>
#include <thrax/compat/utils.h>
#include <fst/fst.h>
#include <fst/project.h>
#include <fst/rmepsilon.h>
#include <fst/shortest-path.h>
#include <fst/string.h>
#include <fst/symbol-table.h>
#include <fst/vector-fst.h>
#include <thrax/grm-manager.h>
#include <thrax/symbols.h>

using fst::StdArc;
using fst::StringCompiler;
using fst::StringPrinter;
using fst::SymbolTable;
using fst::VectorFst;
using thrax::File;
using thrax::GrmManager;
using thrax::InputBuffer;
using thrax::OpenOrDie;
using thrax::Split;

typedef StringCompiler<StdArc> Compiler;
typedef StringPrinter<StdArc> Printer;
typedef VectorFst<StdArc> Transducer;

DEFINE_string(far, "", "Path to the FAR.");
DEFINE_string(input_mode, "byte", "Either \"byte\", \"utf8\", or the path to a "
              "symbol table for input parsing.");
DEFINE_string(output_mode, "byte", "Either \"byte\", \"utf8\", or the path to "
              "a symbol table for input parsing.");
DEFINE_string(separator, "|", "Field separator for file mode.");
DEFINE_string(testdata, "",
	      "Name of file containing tab-separated rule, input, output "
	      "triples");

enum TokenType { SYMBOL = 1, BYTE = 2, UTF8 = 3 };

bool ReadInput(string* s) {
  cout << "Input string: ";
  return static_cast<bool>(getline(cin, *s));
}

bool RewriteOutput(Printer* printer, Transducer* fst,
                   string* output) {
  GrmManager::StringifyFst(fst);
  return printer->operator()(*fst, output);
}

int main(int argc, char** argv) {
  std::set_new_handler(FailedNewHandler);
  SetFlags(argv[0], &argc, &argv, true);

  GrmManager grm;
  CHECK(grm.LoadArchive(FLAGS_far));

  Compiler* compiler = NULL;
  SymbolTable* input_symtab = NULL;
  if (FLAGS_input_mode == "byte") {
    compiler = new Compiler(Compiler::BYTE);
  } else if (FLAGS_input_mode == "utf8") {
    compiler = new Compiler(Compiler::UTF8);
  } else {
    input_symtab = SymbolTable::ReadText(FLAGS_input_mode);
    CHECK(input_symtab);
    compiler = new Compiler(Compiler::SYMBOL, input_symtab);
  }

  Printer* printer = NULL;
  SymbolTable* output_symtab = NULL;
  TokenType type;
  // The type set based on the output_mode is used to check
  // compatibility of the input and rule transducer. If the rule
  // transducer has symbol tables, and the type set here matches, then
  // set the input's symbol tables appropriately.
  if (FLAGS_output_mode == "byte") {
    type = BYTE;
    printer = new Printer(Printer::BYTE);
  } else if (FLAGS_output_mode == "utf8") {
    type = UTF8;
    printer = new Printer(Printer::UTF8);
  } else {
    type = SYMBOL;
    output_symtab = SymbolTable::ReadText(FLAGS_output_mode);
    CHECK(output_symtab);
    printer = new Printer(Printer::SYMBOL, output_symtab);
  }

  int exit_status = 0;
  File* fp = OpenOrDie(FLAGS_testdata, "r");
  string line;
  int linenum;
  const fst::SymbolTable* byte_symtab = NULL;
  const fst::SymbolTable* utf8_symtab = NULL;
  for (InputBuffer ibuf(fp); ibuf.ReadLine(&line);
       /* ReadLine() automatically increments */) {
    vector<string> fields = Split(line, FLAGS_separator.c_str());
    if (fields.size() != 3) continue;
    string rule = fields[0];
    string input = fields[1];
    string output = fields[2];
    if (rule.empty() || rule[0] == '#') continue;
    Transducer input_fst, output_fst;
    string test_output;
    fst::Fst<StdArc>* fst = grm.GetFst(rule);
    if (!fst) {
      LOG(FATAL) << "grm.GetFst() must be non NULL: " << rule;
    }
    Transducer vfst(*fst);
    // If the input transducers in the FAR have symbol tables then we
    // need to add the appropriate symbol table(s) to the input
    // strings, according to the parse mode. For byte and utf8 symbol
    // tables we create them here. This will only have to be done for
    // the first line in the test file.
    if (vfst.InputSymbols()) {
      if (!byte_symtab &&
          vfst.InputSymbols()->Name() ==
          thrax::function::kByteSymbolTableName) {
        byte_symtab = vfst.InputSymbols()->Copy();
      } else if (!utf8_symtab &&
                 vfst.InputSymbols()->Name() ==
                 thrax::function::kUtf8SymbolTableName) {
        utf8_symtab = vfst.InputSymbols()->Copy();
      }
    }
    if (!compiler->operator()(input, &input_fst)) {
      cout << "Unable to parse input string: " << input << endl;
      exit_status = 1;
      continue;
    }
    // Set symbols for the input, if appropriate
    if (byte_symtab && type == BYTE) {
      input_fst.SetInputSymbols(byte_symtab);
      input_fst.SetOutputSymbols(byte_symtab);
    } else if (utf8_symtab && type == UTF8) {
      input_fst.SetInputSymbols(utf8_symtab);
      input_fst.SetOutputSymbols(utf8_symtab);
    } else if (input_symtab && type == SYMBOL) {
      input_fst.SetInputSymbols(input_symtab);
      input_fst.SetOutputSymbols(input_symtab);
    }
    if (!grm.Rewrite(rule, input_fst, &output_fst) ||
	!RewriteOutput(printer, &output_fst, &test_output) ||
	test_output != output) {
      cout << "Match failed:\t" << line << endl;
      cout << "Actual:\t" << test_output << endl;
      cout << "Expected:\t" << output << endl;
      exit_status = 1;
    }
  }
  if (!exit_status) cout << "PASS" << endl;

  delete compiler;
  delete printer;
  delete input_symtab;
  delete output_symtab;

  return exit_status;
}
