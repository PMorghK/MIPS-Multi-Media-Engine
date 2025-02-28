#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int process_line (const char* line, FILE*);

int main (int argc, char* argv[])
{
	if (argc != 3) 
	{
		fprintf(stderr, "Usage: %s <input_file> <output_file>\n", argv[0]);
		return -1;
	}

	FILE* input_file;
	FILE* output_file;
	input_file = fopen(argv[1], "r");
	output_file = fopen(argv[2], "w");

	if (!input_file) 
	{
		perror("Error opening file");
		return -1;
	}
	if (!output_file) 
	{
		perror("Error opening file");
		return -1;
	}

	char line[256];

	while (fgets(line, sizeof(line), input_file)) 
	{
		line[strcspn(line, "\n")] = '\0';

		if (line[0] == '\0' || line[0] == '#') 
			continue;

		process_line(line, output_file);
	}

	fclose(output_file);
	fclose(input_file);
	return 0;
}

int process_line (const char* line, FILE* output_file)
{
	char binary[26];
	char line_copy[256];
	int number;

	strncpy(line_copy, line, sizeof(line_copy));

	line_copy[sizeof(line_copy) - 1] = '\0';  // Ensure null-termination
	binary[25] = '\0';

	char* token;
	int token_index;
	token = strtok(line_copy, ", \n\t");
	token_index = 0;

	if (token != NULL)
	{
		// OP_LI
		if (strcasecmp(token, "LI") == 0)
		{
			while (token != NULL)
			{
				if (*token == '$')
					token++;

				number = atoi(token);

				switch (token_index)
				{
					// Set Instruction Format.
					case 0:
						binary[0] = '0';

						break;

						// Set RD in binary.
					case 1:
						for(int i = 0; i < 5; i++)
						{
							binary[24 - i] = (number & 1) + '0';
							number = number >> 1;
						}

						break;

						// Set Load Index in binary.
					case 2:
						for(int i = 0; i < 3; i++)
						{
							binary[3 - i] = (number & 1) + '0';
							number = number >> 1;
						}

						break;

						// Set Immediate Field in binary.
					case 3:
						for(int i = 0; i < 16; i++)
						{
							binary[19 - i] = (number & 1) + '0';
							number = number >> 1;

						}

						break;

					default:
						fprintf(stderr, "Unexpected token: %s\n", token);
						return -1;
				}

				token = strtok(NULL, ", \n\t");
				token_index++;
			}

			if ((token_index != 4))
			{
				fprintf(stderr, "Syntax Error: Wrong use of LI.\n");
				return -1;
			}
		}

		// OP_group_R4
		else if (strcasecmp(token, "IMAL") == 0 ||
				strcasecmp(token, "IMAH") == 0 ||
				strcasecmp(token, "IMSL") == 0 ||
				strcasecmp(token, "IMSH") == 0 ||
				strcasecmp(token, "LMAL") == 0 ||
				strcasecmp(token, "LMAH") == 0 ||
				strcasecmp(token, "LMSL") == 0 ||
				strcasecmp(token, "LMSH") == 0)
		{
			while (token != NULL)
			{
				switch (token_index)
				{
					// Set Instruction Opcode in binary.
					case 0:
						binary[0] = '1';
						binary[1] = '0';

						if (*token == 'I' || *token == 'i')
							binary[2] = '0';

						else
							binary[2] = '1';

						if (*(token + 2) == 'A' || *token == 'a')
							binary[3] = '0';

						else
							binary[3] = '1';

						if (*(token + 3) == 'L' || *token == 'l')
							binary[4] = '0';

						else
							binary[4] = '1';

						break;

					case 1:
						if (*token == '$')
							token++;

						number = atoi(token);

						for(int i = 0; i < 5; i++)
						{
							binary[24 - i] = (number & 1) + '0';
							number = number >> 1;
						}

						break;

					case 2:
						if (*token == '$')
							token++;

						number = atoi(token);

						for(int i = 0; i < 5; i++)
						{
							binary[19 - i] = (number & 1) + '0';
							number = number >> 1;
						}

						break;

					case 3:
						if (*token == '$')
							token++;

						number = atoi(token);

						for(int i = 0; i < 5; i++)
						{
							binary[14 - i] = (number & 1) + '0';
							number = number >> 1;
						}

						break;

					case 4:
						if (*token == '$')
							token++;

						number = atoi(token);

						for(int i = 0; i < 5; i++)
						{
							binary[9 - i] = (number & 1) + '0';
							number = number >> 1;
						}

						break;

					default:
						fprintf(stderr, "Unexpected token: %s\n", token);
						return -1;

				}

				token = strtok(NULL, ", \n\t");
				token_index++;
			}

			if ((token_index != 5))
			{
				fprintf(stderr, "Syntax Error: Wrong use of instruction.\n");
				return -1;
			}

		}

		else if (strcasecmp(token, "NOP") == 0)
		{
			snprintf(binary, 26, "1100000000000000000000000");
		}

		// OP_group_R4
		else if (strcasecmp(token, "SLHI") == 0 ||
				strcasecmp(token, "AU") == 0 ||
				strcasecmp(token, "CNT1H") == 0 ||
				strcasecmp(token, "AHS") == 0 ||
				strcasecmp(token, "AND") == 0 ||
				strcasecmp(token, "BCW") == 0 ||
				strcasecmp(token, "MAXWS") == 0 ||
				strcasecmp(token, "MINWS") == 0 ||
				strcasecmp(token, "MLHU") == 0 ||
				strcasecmp(token, "MLHCU") == 0 ||
				strcasecmp(token, "OR") == 0 ||
				strcasecmp(token, "CLZH") == 0 ||
				strcasecmp(token, "RLH") == 0 ||
				strcasecmp(token, "SFWU") == 0 ||
				strcasecmp(token, "SFHS") == 0)
		{
			while (token != NULL)
			{
				switch (token_index)
				{
					// Set Instruction Opcode in binary.
					case 0:
						binary[0] = '1';
						binary[1] = '1';

						binary[2] = '0';
						binary[3] = '0';
						binary[4] = '0';
						binary[5] = '0';

						if (strcasecmp(token, "SLHI") == 0)
						{
							binary[6] = '0';
							binary[7] = '0';
							binary[8] = '0';
							binary[9] = '1';
						}
						else if (strcasecmp(token, "AU") == 0) 
						{
							binary[6] = '0';
							binary[7] = '0';
							binary[8] = '1';
							binary[9] = '0';
						}
						else if (strcasecmp(token, "CNT1H") == 0)
						{
							binary[6] = '0';
							binary[7] = '0';
							binary[8] = '1';
							binary[9] = '1';
						}
						else if (strcasecmp(token, "AHS") == 0)
						{
							binary[6] = '0';
							binary[7] = '1';
							binary[8] = '0';
							binary[9] = '0';
						}
						else if (strcasecmp(token, "AND") == 0)
						{
							binary[6] = '0';
							binary[7] = '1';
							binary[8] = '0';
							binary[9] = '1';
						}
						else if (strcasecmp(token, "BCW") == 0)
						{
							binary[6] = '0';
							binary[7] = '1';
							binary[8] = '1';
							binary[9] = '0';
						}
						else if (strcasecmp(token, "MAXWS") == 0)
						{
							binary[6] = '0';
							binary[7] = '1';
							binary[8] = '1';
							binary[9] = '1';
						}
						else if (strcasecmp(token, "MINWS") == 0)
						{
							binary[6] = '1';
							binary[7] = '0';
							binary[8] = '0';
							binary[9] = '0';
						}
						else if (strcasecmp(token, "MLHU") == 0)
						{
							binary[6] = '1';
							binary[7] = '0';
							binary[8] = '0';
							binary[9] = '1';
						}
						else if (strcasecmp(token, "MLHCU") == 0)
						{
							binary[6] = '1';
							binary[7] = '0';
							binary[8] = '1';
							binary[9] = '0';
						}
						else if (strcasecmp(token, "OR") == 0)
						{
							binary[6] = '1';
							binary[7] = '0';
							binary[8] = '1';
							binary[9] = '1';
						}
						else if (strcasecmp(token, "CLZH") == 0)
						{
							binary[6] = '1';
							binary[7] = '1';
							binary[8] = '0';
							binary[9] = '0';
						}
						else if (strcasecmp(token, "RLH") == 0)
						{
							binary[6] = '1';
							binary[7] = '1';
							binary[8] = '0';
							binary[9] = '1';
						}
						else if (strcasecmp(token, "SFWU") == 0)
						{
							binary[6] = '1';
							binary[7] = '1';
							binary[8] = '1';
							binary[9] = '0';
						}
						else if (strcasecmp(token, "SFHS") == 0)
						{
							binary[6] = '1';
							binary[7] = '1';
							binary[8] = '1';
							binary[9] = '1';
						}

						break;

						// Set RD in binary.
					case 1:
						if (*token == '$')
							token++;

						number = atoi(token);

						for(int i = 0; i < 5; i++)
						{
							binary[24 - i] = (number & 1) + '0';
							number = number >> 1;
						}

						break;

						// Set RS1 in binary.
					case 2:
						if (*token == '$')
							token++;

						number = atoi(token);

						for(int i = 0; i < 5; i++)
						{
							binary[19 - i] = (number & 1) + '0';
							number = number >> 1;
						}

						break;

						// Set RS2 in binary.
					case 3:
						if (*token == '$')
							token++;

						number = atoi(token);

						for(int i = 0; i < 5; i++)
						{
							binary[14 - i] = (number & 1) + '0';
							number = number >> 1;
						}

						break;

					default:
						fprintf(stderr, "Unexpected token: %s\n", token);
						return -1;

				}

				token = strtok(NULL, ", \n\t");
				token_index++;
			}

			if ((token_index != 4))
			{
				fprintf(stderr, "Syntax Error: Wrong use of instruction.\n");
				return -1;
			}
		}

		else
		{
			fprintf(stderr, "Syntax Error: No such instruction: %s\n", token);
			return -1;
		}
	}
	else 
		return 0;

	fprintf(output_file, "%s\n", binary);

	return 0;
}
