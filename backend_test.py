import requests
import json
from datetime import datetime

# Use the public backend URL
BACKEND_URL = "https://ball-blast-neon-1.preview.emergentagent.com/api"

def print_test_result(test_name, passed, details=""):
    status = "✅ PASS" if passed else "❌ FAIL"
    print(f"\n{status}: {test_name}")
    if details:
        print(f"   Details: {details}")

def test_health_check():
    """Test GET /api/health"""
    try:
        response = requests.get(f"{BACKEND_URL}/health", timeout=10)
        passed = response.status_code == 200 and response.json().get("status") == "ok"
        print_test_result("Health Check", passed, f"Status: {response.status_code}, Response: {response.json()}")
        return passed
    except Exception as e:
        print_test_result("Health Check", False, f"Error: {str(e)}")
        return False

def test_create_player():
    """Test POST /api/player/create"""
    try:
        player_data = {
            "playerId": f"test_player_{datetime.now().timestamp()}",
            "coins": 100,
            "gems": 50,
            "currentPhase": 1
        }
        response = requests.post(f"{BACKEND_URL}/player/create", json=player_data, timeout=10)
        passed = response.status_code == 200 and "_id" in response.json()
        result = response.json()
        print_test_result("Create Player", passed, f"Status: {response.status_code}, Player ID: {result.get('playerId')}")
        return passed, result.get("playerId") if passed else None
    except Exception as e:
        print_test_result("Create Player", False, f"Error: {str(e)}")
        return False, None

def test_get_player(player_id):
    """Test GET /api/player/{player_id}"""
    try:
        response = requests.get(f"{BACKEND_URL}/player/{player_id}", timeout=10)
        passed = response.status_code == 200 and response.json().get("playerId") == player_id
        print_test_result("Get Player", passed, f"Status: {response.status_code}, Player: {response.json().get('playerId')}")
        return passed
    except Exception as e:
        print_test_result("Get Player", False, f"Error: {str(e)}")
        return False

def test_update_player(player_id):
    """Test PUT /api/player/{player_id}/update"""
    try:
        updates = {
            "coins": 200,
            "gems": 100
        }
        response = requests.put(f"{BACKEND_URL}/player/{player_id}/update", json=updates, timeout=10)
        passed = response.status_code == 200 and response.json().get("success") == True
        print_test_result("Update Player", passed, f"Status: {response.status_code}, Response: {response.json()}")
        return passed
    except Exception as e:
        print_test_result("Update Player", False, f"Error: {str(e)}")
        return False

def test_get_phases():
    """Test GET /api/phases"""
    try:
        response = requests.get(f"{BACKEND_URL}/phases", timeout=10)
        phases = response.json()
        passed = (response.status_code == 200 and 
                 isinstance(phases, list) and 
                 len(phases) == 5 and
                 all(key in phases[0] for key in ["id", "name", "description", "difficulty", "color", "shape", "targetHP"]))
        print_test_result("Get Phases", passed, f"Status: {response.status_code}, Phases count: {len(phases)}")
        return passed
    except Exception as e:
        print_test_result("Get Phases", False, f"Error: {str(e)}")
        return False

def test_start_session(player_id):
    """Test POST /api/session/start"""
    try:
        session_data = {
            "playerId": player_id,
            "phase": 1,
            "currentXP": 0,
            "level": 1,
            "temporaryUpgrades": [],
            "score": 0,
            "coinsEarned": 0
        }
        response = requests.post(f"{BACKEND_URL}/session/start", json=session_data, timeout=10)
        passed = response.status_code == 200 and "_id" in response.json()
        result = response.json()
        print_test_result("Start Session", passed, f"Status: {response.status_code}, Session ID: {result.get('_id')}")
        return passed, result.get("_id") if passed else None
    except Exception as e:
        print_test_result("Start Session", False, f"Error: {str(e)}")
        return False, None

def test_ads_reward(player_id):
    """Test POST /api/ads/reward"""
    try:
        reward_data = {
            "playerId": player_id,
            "adType": "video",
            "rewardType": "coins",
            "rewardAmount": 50
        }
        response = requests.post(f"{BACKEND_URL}/ads/reward", json=reward_data, timeout=10)
        passed = response.status_code == 200 and response.json().get("success") == True
        print_test_result("Ads Reward", passed, f"Status: {response.status_code}, Response: {response.json()}")
        return passed
    except Exception as e:
        print_test_result("Ads Reward", False, f"Error: {str(e)}")
        return False

def test_unlock_phase(player_id):
    """Test POST /api/player/{player_id}/unlock-phase"""
    try:
        response = requests.post(f"{BACKEND_URL}/player/{player_id}/unlock-phase", params={"phase_id": 2}, timeout=10)
        passed = response.status_code == 200 and response.json().get("success") == True
        print_test_result("Unlock Phase", passed, f"Status: {response.status_code}, Response: {response.json()}")
        return passed
    except Exception as e:
        print_test_result("Unlock Phase", False, f"Error: {str(e)}")
        return False

def test_purchase_upgrade(player_id):
    """Test POST /api/player/{player_id}/purchase-upgrade"""
    try:
        response = requests.post(
            f"{BACKEND_URL}/player/{player_id}/purchase-upgrade",
            params={"upgrade_name": "damage_boost", "cost": 50},
            timeout=10
        )
        passed = response.status_code == 200 and response.json().get("success") == True
        print_test_result("Purchase Upgrade", passed, f"Status: {response.status_code}, Response: {response.json()}")
        return passed
    except Exception as e:
        print_test_result("Purchase Upgrade", False, f"Error: {str(e)}")
        return False

def test_error_handling():
    """Test error handling for invalid requests"""
    try:
        # Test getting non-existent player
        response = requests.get(f"{BACKEND_URL}/player/nonexistent_player", timeout=10)
        passed = response.status_code == 404
        print_test_result("Error Handling - Non-existent Player", passed, f"Status: {response.status_code}")
        return passed
    except Exception as e:
        print_test_result("Error Handling", False, f"Error: {str(e)}")
        return False

def run_all_tests():
    print("=" * 80)
    print("NEON IDLE GAME - BACKEND API TESTING")
    print("=" * 80)
    print(f"Backend URL: {BACKEND_URL}")
    print("=" * 80)
    
    results = {}
    
    # Test 1: Health Check
    results["health_check"] = test_health_check()
    
    # Test 2: Create Player
    create_passed, player_id = test_create_player()
    results["create_player"] = create_passed
    
    if player_id:
        # Test 3: Get Player
        results["get_player"] = test_get_player(player_id)
        
        # Test 4: Update Player
        results["update_player"] = test_update_player(player_id)
        
        # Test 5: Get Phases
        results["get_phases"] = test_get_phases()
        
        # Test 6: Start Session
        session_passed, session_id = test_start_session(player_id)
        results["start_session"] = session_passed
        
        # Test 7: Ads Reward
        results["ads_reward"] = test_ads_reward(player_id)
        
        # Test 8: Unlock Phase
        results["unlock_phase"] = test_unlock_phase(player_id)
        
        # Test 9: Purchase Upgrade
        results["purchase_upgrade"] = test_purchase_upgrade(player_id)
    else:
        print("\n⚠️  Skipping remaining tests due to player creation failure")
    
    # Test 10: Error Handling
    results["error_handling"] = test_error_handling()
    
    # Summary
    print("\n" + "=" * 80)
    print("TEST SUMMARY")
    print("=" * 80)
    passed_count = sum(1 for v in results.values() if v)
    total_count = len(results)
    print(f"Total Tests: {total_count}")
    print(f"Passed: {passed_count}")
    print(f"Failed: {total_count - passed_count}")
    print(f"Success Rate: {(passed_count/total_count)*100:.1f}%")
    print("=" * 80)
    
    return results

if __name__ == "__main__":
    run_all_tests()
