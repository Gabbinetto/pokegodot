
class FunctionCodes():

    def extract(self, file_path, prefix='FunctionCode = '):
        
        OUTPUT_PATH = './function_codes.txt'

        output = []

        with open(file_path, 'r') as f:
            for line in f:
                if line.startswith(prefix):
                    code = line.replace(prefix, '')

                    if code not in output:
                        output.append(code)
        
        with open(OUTPUT_PATH, 'w') as f:
            f.writelines(output)

if __name__ == '__main__':
    extractor = FunctionCodes()
    extractor.extract('../PBS/moves.txt')
