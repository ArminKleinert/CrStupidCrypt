# CrStupidCrypt

I wrote this program as a simple test of the Crystal programming language.

## Installation

If you want to change or extend the code, clone the repository.  
```git clone https://github.com/ArminKleinert/CrStupidCrypt.git```

If you just want to use the program, you can download the executable (for linux) from the ./bin directory.

## Usage

Call the executable as follows:  
```CrStupidCrypt <source> <destination> <secret-code> <options>```

```<source>``` is the file that you want to encrypt/decrypt.  
```<destination>``` is the file which the output will be written to. The output is not human-readable at all.  
```<secret-code>``` is a 32-bit number, given in hex-format (prefix: 0x), binary-format (prefix: 0b), octal-format (prefix: 0o) or decimal format (no prefix).  
```<options>``` are attional options, all starting with "--". The most important (and at the moment the only) option is "--decrypt".

Example for encryption:  
```CrStupidCrypt originalfile encryptedfile 0xCAFEBABE```  
Example for decryption:  
```CrStupidCrypt encryptedfile decryptedfile 0xCAFEBABE --decrypt```

For convenience, the source- and destination-files can be the same. This way, the file is edited in-place.

## Contributors

- [armin] https://github.com/ArminKleinert - creator and maintainer
