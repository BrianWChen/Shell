function sort(ARRAY, ELEMENTS,     temp, i, j){
	for ( i = 2; i <= ELEMENTS; ++i )
		for ( j = i; ARRAY[j-1] > ARRAY[j]; --j ){
			temp = ARRAY[j]
			ARRAY[j] = ARRAY[j-1]
			ARRAY[j-1] = temp
		}
	return
}

{
	for ( i = 2; i <= NF; ++i)
		grades[i-1] = $i
	sort(grades, NF-1)
	printf("%s: ", $1)
	for( j = 1; j <= NF-1; ++j)
		printf("%d ", grades[j])
	printf("\n")
}
