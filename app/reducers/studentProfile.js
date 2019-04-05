const initialState = {
	profile: { data: null },
	name: { data: null },
	image: { data: null }
}

function studentProfileReducer(state = initialState, action) {
	const newState = { ...state }
	switch (action.type) {
		case 'SET_STUDENT_PROFILE':
			newState.profile.data = action.profile
			return newState
		case 'SET_STUDENT_NAME':
			newState.name.data = action.name
			return newState
		case 'SET_STUDENT_PHOTO':
			newState.image.data = action.image
			return newState
		case 'CLEAR_STUDENT_PROFILE_DATA':
			return initialState
		default:
			return state
	}
}

module.exports = studentProfileReducer
