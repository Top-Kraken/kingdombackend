function request(type,data) {
    if( type == 'Number') {
      $.ajax({
        type:"GET",
        url:"leads",
        dataType:"json",
        data: {number: data},
        success: function(data) { $("#leads-container")[0].innerHTML = data.html; }
      })
    } else if( type == 'Letters'){
      $.ajax({
        type:"GET",
        url:"leads",
        dataType:"json",
        data: {name: data},
        success: function(data) { $("#leads-container")[0].innerHTML = data.html; }
      })
    }
    else {
      $.ajax({
        type:"GET",
        url:"leads",
        dataType:"json",
        data: {default: data},
        success: function(data) { $("#leads-container")[0].innerHTML = data.html; }
      })
    }
  }
  
  window.addEventListener('load', () => {
    let input = document.getElementById('myInput');
    input.addEventListener('keypress', (event) => {
      console.log(event.key);
      if (event.key == "Enter") {
  
        const input = event.target.value;
        const contacts = document.getElementsByClassName('contactItem');
  
          if( input.match(/^[0-9]+$/) != null ) {
            request('Number', input);
          } else if ( !/[^a-zA-Z]/.test(input) ) {
            console.log(input === "")
            if( input === "") request('default', input);
            else request('Letters', input);
          }
      }
    })
  })
  