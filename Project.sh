#This functions performs the operation when +,&,| or ^ commands are entered
arithmeticLogicOp() 
{
	operation=$1  #take the first and only parameter sent to the function
	
	#to delete the the operation symbol from the stack
	sed -i '$ d' Stack
					
	#take the first number and delete it from the stack
	num1=$(tail -1 Stack)
	sed -i '$ d' Stack
				
	#check if value saved in num1 is an integer or not
	if ! [[ "$num1" =~ ^[0-9]+$ ]]
  	then
  		#if it's not an integer set the flag for it to 1
  		isNum1Integer="1"
  	else
  		isNum1Integer="0"
  	fi
		
	#take the second number and delete it from the stack
	num2=$(tail -1 Stack)
	sed -i '$ d' Stack 
				
	if ! [[ "$num2" =~ ^[0-9]+$ ]]
  	then
  		#if it not an integer set the flag for it to 1
  		isNum2Integer="1"
  	else
  		isNum2Integer="0"
  	fi
  				
  	# if both are values are interger perform the operation
  	if [ $isNum1Integer = 0 -a $isNum2Integer = 0 ]
  	then
  		result=$(( num1 $operation num2 ))
		echo $result >> Stack
  	else
  		#return the value deleted from the stack
  		echo "$num2" >> Stack
  		echo "$num1" >> Stack
  		echo "$operation" >> Stack
  					
  		echo "ERROR. CAN'T PERFORM THE OPERATION, THE LAST TWO ELEMENTS MUST BE INTEGERS"
				
	fi
}

#This function is used when reading from console and from a file.
#It processes the command entered and performs the suitable operation

operations() #the function takes one parameter only
{
	command=$1 #take the first argument when calling the function
		
	#check if the command is an integer of any number of digits
  	if ! [[ "$command" =~ ^[0-9]+$ ]]
  	then
  		integer="1"
  	else
  		integer="0"
  	fi

  	#if it's integer or , the s command or the + sign .. push to the stack
	if [ $integer = "0" -o $command = "s" -o $command = "+" -o $command = "d" -o $command = "&" -o $command = "^" -o $command = "|" ] 
	then
		echo $command >> Stack
		
	elif [ $command = "e" ] #the last operation will be executed
	then
		#print the stack before executing
		printf "e "
		tail -1 UndoStack
			
		top=$(tail -1 Stack)
		
		if [[ $(tail -1 Stack) = 's' ]] #the last operation is swap operation
		then
			# save number of lines in stack and check if swap is valid
			count=$(cat Stack | wc -l)
				
			#swap is valid if there are two elements before 's'
			if [ $count -lt 3 ]
			then
				echo "ERROR: THERE SHOULD BE 2 VALUES BEFORE 's' TO DO SWAP OPERATION"
			else
				sed -i '$ d' Stack  #delete 's' from the stack
			
				#save the last input before 's' to swap1 and delete it from the stack
				swap1=$(tail -1 Stack)
				sed -i '$ d' Stack
			
				#save the last input before swap1 to swap2 and delete it from the stack
				swap2=$(tail -1 Stack)
				sed -i '$ d' Stack
				
				#push the values again but in the opposite order of reading them
				echo $swap1 >> Stack
				echo $swap2 >> Stack
			fi
				
				
		elif [[ $(tail -1 Stack) = 'd' ]]
		then
			#to delete the d command
			sed -i '$ d' Stack
			
			if [ -s Stack ]
			then
				sed -i '$ d' Stack
			else
				echo "d" >> Stack
			fi
				
		elif [[ $(tail -1 Stack) = '+' ]] #if the last operation is addition
		then
			arithmeticLogicOp $top
				
		elif [[ $(tail -1 Stack) = '&' ]] #if the operation is &
		then
			arithmeticLogicOp $top
				
		elif [[ $(tail -1 Stack) = '^' ]] #if the operation is ^
		then
			arithmeticLogicOp $top
				
		elif [[ $(tail -1 Stack) = '|' ]] #if the operation is |
		then
			arithmeticLogicOp $top	
			
		fi
			
		
	elif [ $command = "p" ] #print the stack		
	then
		printf "p "
		tail -1 UndoStack #last line of undoStack is the current stack	
			
	elif [ $command = "x" ]
	then
		printf "x "
		tail -1 UndoStack #last line of undoStack is the current stack
		printf "\nTHANK YOU FOR USING OUR PROGRAM\n"
		exit 
	
	else #if non of the valid commands is entered
		echo "ERROR: INVALID COMMAND,PLEASE TRY AGAIN"		
	fi	
	

	#after each command entered print the stack
	if [ -s Stack ] 
        then
              	#save the resulting stack to undoStack
              	tac Stack | tr '\12' ' ' >> UndoStack
		echo "" >> UndoStack
        	      
        	      	
        	#print the stack
              	tail -1 UndoStack
			
	else #if the stack is empty
		cat Stack > UndoStack
		echo
		echo "THE STACK IS EMPTY"
	fi

}

Menu()
{
	printf "\nYou can enter any of the follwoing commands\n"
	printf "\nAny integer : push the integer int on the stack\n"
	printf "+ : push a '+' on the stack\n"
	printf "s : push an 's' on the stack\n"
	printf "e : evaluate the top of the stack\n"
	printf "p : print content of the stack\n"
	printf "d : delete the top of the stack\n"
	printf "u : undo the last command\n"
	printf "x : stop and exit the program\n"
	printf "& : push a '&' on the stack\n"
	printf "^ : push a '^' on the stack\n"
	printf "| : push a '|' on the stack\n"

}


#make both of the files empty before starting
> Stack
> UndoStack


echo "---------Welcome to our program------------"

#to see if the user want to use the console or a file to read from
printf "\nPLEASE ENTER (1) IF YOU WANT TO READ FROM A FILE\nOR ANY NUMBER TO READ FROM THE CONSOLE\n"

read choice


if [[ $choice = "1" ]] #choice is to read from file
	then
	
		#show the menu to the user
		Menu
		
		echo
		echo "PLEASE ENTER THE FILE NAME: "
		read fileName 
		
		#while loop keeps repeating until the user enters an existing file name
		while [ ! -e $fileName -o ! -f $fileName ]
		do
		  echo
		  echo "ERROR: FILE DOES NOT EXIST IN THE CURRENT DIRECTORY OR IT'S NOT AN ORDINARY FILE. PLEASE TRY AGAIN"
		   echo
		  echo "Please enter the file name : "
		  read fileName 
		done
		
		if [ -s $fileName ]
		then
			#loop through the file and perform the operation each time
			while read command;
			do
				echo
				echo "> $command"
				operations $command
		
			done < $fileName
		else
			echo "The file is empty"
		fi
			
		#the program finishes when entering x in the file or when the file ends
		printf "\nThank you for using our program\n"
		
		
#if the user chose to read from the console
else
	flg=1
	while [[ $flg != x ]]
	do
		#show the menu to the user
		Menu
	
		
		printf ">"
		#read the command
		read command
		
		#check if u is entered
		if [ $command = "u" ]
		then
			#the undo process
			sed -i '$ d' UndoStack 
			
			#move the last line in undoStack to Stack
			tail -1 UndoStack | tr ' ' '\12' | tac > Stack
			
			sed -i '1d' Stack 
			
			if [ -s Stack ] 
        		then
        			#print the stack
              			tail -1 UndoStack
			
			else #if the stack is empty
				cat Stack > UndoStack
				echo
				echo "THE STACK IS EMPTY"
			fi        	      	
		else	
			operations $command 
		fi
		
				
	done


fi


