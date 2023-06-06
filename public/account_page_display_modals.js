 function showImages() {
    const imageSection = document.querySelector('#image-section');
    const mapSection = document.querySelector('#map-section');
    const followingSection = document.querySelector('#following-section');

    imageSection.style.display = 'block';
    mapSection.querySelector('#your-visible-map-container').id = 'your-hidden-map-container';
    followingSection.style.display = 'none';
  }

  function showMap() {
    const imageSection = document.querySelector('#image-section');
    const mapSection = document.querySelector('#map-section');
    const followingSection = document.querySelector('#following-section');

    imageSection.style.display = 'none';
    mapSection.querySelector('#your-hidden-map-container').id = 'your-visible-map-container';
    followingSection.style.display = 'none';
  }

  function showFollowing() {
    const imageSection = document.querySelector('#image-section');
    const mapSection = document.querySelector('#map-section');
    const followingSection = document.querySelector('#following-section');

    imageSection.style.display = 'none';
    mapSection.querySelector('#your-visible-map-container').id = 'your-hidden-map-container';
    followingSection.style.display = 'block';
  }
