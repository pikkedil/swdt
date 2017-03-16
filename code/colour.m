function col = colour(ph)

    switch ph
        case(1)
            col = 'red';
        case(-1)
            col = 'red';
        case(2)
            col = 'blue';
        case(-2)
            col = 'blue';
        case(3)
            col = 'yellow';
        case(-3)
            col = 'yellow';
    end
end