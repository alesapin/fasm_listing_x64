# Flat assembler listing 
Fasm listing tool, for x86_64 - linux.

Compile:

  fasm listing64.asm
  
  gcc -s listing64.o -o listing

Use:

  fasm some_name.asm -s some_name.fas

  listing some_name.fas some_name.lst

